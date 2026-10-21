class_name GameStats
extends RefCounted

enum StatNames {
	PLAYER_POINTS,
	COMPUTER_POINTS,
	HOUSE_BANK,
	PLAYER_DEFENSE,
	COMPUTER_DEFENSE,
	PLAYER_OVERSHIELD,
	COMPUTER_OVERSHIELD,
	CURRENT_STREAK,
	BEST_STREAK,
	TOTAL_ROUNDS,
	TIMER_LENGTH,
	WINS,
	LOSSES,
	DRAWS
}

enum RoundOutcome {
	WIN,
	LOSS,
	DRAW,
	DISCARD,
	CLEARED
}

enum ResolutionScenario {
	NONE,
	SCENARIO_A_HONEST_WIN_NEG_WEIGHT,
	SCENARIO_B_HONEST_WIN_POS_WEIGHT,
	SCENARIO_C_SNIPE_SUCCESS,
	SCENARIO_D_DOUBLE_SNIPE_PENALTY,
	SCENARIO_E_HONEST_SAME_SUIT_WEIGHT_WIN,
	SCENARIO_F_SNIPE_FAILED_DEFENSE_IGNORED,
	SCENARIO_G_HONEST_EXACT_TIE
}

const RPLS_BEATS: Dictionary = {
	CardBase.Suit.ROCK: [CardBase.Suit.SCISSORS, CardBase.Suit.LIZARD],
	CardBase.Suit.PAPER: [CardBase.Suit.ROCK, CardBase.Suit.SPOCK],
	CardBase.Suit.SCISSORS: [CardBase.Suit.PAPER, CardBase.Suit.LIZARD],
	CardBase.Suit.LIZARD: [CardBase.Suit.PAPER, CardBase.Suit.SPOCK],
	CardBase.Suit.SPOCK: [CardBase.Suit.ROCK, CardBase.Suit.SCISSORS]
}

var player_state: PlayerState = PlayerState.new()
var computer_state: PlayerState = PlayerState.new()

var house_bank: int = 0
var house_suit: CardBase.Suit = CardBase.Suit.ROCK
var next_house_suit: CardBase.Suit = CardBase.Suit.PAPER
var house_history: Array[String] = []

var player_turn_move: ChosenCards = null
var computer_turn_move: ChosenCards = null
var player_move: String = ""
var computer_move: String = ""

var outcome: RoundOutcome = RoundOutcome.CLEARED
var last_scenario: ResolutionScenario = ResolutionScenario.NONE
var last_round_summary: String = ""

# These actually use the PlayerRoundState variables
# These are purely for Triggers and Effects
var player_points: float:
	get: return float(player_state.bank)
	set(val): player_state.bank = int(val)

var computer_points: float:
	get: return float(computer_state.bank)
	set(val): computer_state.bank = int(val)

var player_defense: int:
	get: return player_state.defense
	set(val): player_state.defense = val

var computer_defense: int:
	get: return computer_state.defense
	set(val): computer_state.defense = val

var player_overshield: int:
	get: return player_state.overshield
	set(val): player_state.overshield = val

var computer_overshield: int:
	get: return computer_state.overshield
	set(val): computer_state.overshield = val

var wins: int = 0
var losses: int = 0
var draws: int = 0
var current_streak: int = 0
var best_streak: int = 0
var rounds_played: int = 0
var total_rounds: int = -1
var timer_length: float = 15.0

var previous_outcome: Array[String] = []
var player_history: Array[String] = []
var computer_history: Array[String] = []
var round_activated_modifiers: Array[StringName] = []
var modifier_usage_count: Dictionary[StringName, int] = {}

func _init() -> void:
	house_suit = pick_random_suit()
	next_house_suit = pick_random_suit()

static func does_suit_beat(attacker: CardBase.Suit, defender: CardBase.Suit):
	if attacker == CardBase.Suit.NONE or defender == CardBase.Suit.NONE:
		return false
		
	return defender in RPLS_BEATS.get(attacker, [])

static func is_honest_move(move_suit: CardBase.Suit, current_house_suit: CardBase.Suit):
	return does_suit_beat(move_suit, current_house_suit)

func pick_random_suit() -> CardBase.Suit:
	return CardBase.Suit.values().pick_random()

func advance_house_suit() -> void:
	house_history.append(CardBase.Suit.keys()[house_suit].to_lower())
	house_suit = next_house_suit
	next_house_suit = pick_random_suit()

func reset_round() -> void:
	player_turn_move = null
	computer_turn_move = null
	player_move = ""
	computer_move = ""
	outcome = RoundOutcome.CLEARED
	last_scenario = ResolutionScenario.NONE
	last_round_summary = ""
	rounds_played += 1
	house_bank += 1
	round_activated_modifiers.clear()

func apply_stat_change(stat_change: StatChange) -> void:
	var lower_stat: String = StatNames.keys()[stat_change.target_stat].to_lower()
	var current = get(lower_stat)
	if current == null:
		push_warning("(LoopGameStats) '%s' is not a valid stat" % lower_stat)
		return

	match stat_change.operation:
		StatChange.Operation.ADD:
			set(lower_stat, current + stat_change.value)
		StatChange.Operation.SUBTRACT:
			set(lower_stat, current - stat_change.value)
		StatChange.Operation.DIVIDE:
			set(lower_stat, current / stat_change.value)
		StatChange.Operation.MULTIPLY:
			set(lower_stat, current * stat_change.value)
		StatChange.Operation.SET:
			set(lower_stat, stat_change.value)

func record_round_stats() -> void:
	previous_outcome.append(RoundOutcome.keys()[outcome])
	player_history.append(player_move if not player_move.is_empty() else "none")
	computer_history.append(computer_move if not computer_move.is_empty() else "none")
