extends Control

signal round_resolved(outcome: GameStats.RoundOutcome, scenario: GameStats.ResolutionScenario, summary: String)
signal loser_must_tutor_card(loser_is_player: bool, must_discard_first: bool)
signal empty_hand_reward_requested(is_player: bool)
signal match_ended(player_won: bool, reason: String)

enum Scenarios {
	SCENARIO_A,
	SCENARIO_B,
	SCENARIO_C,
	SCENARIO_D,
	SCENARIO_E,
	SCENARIO_G,
	RANDOMISE
}

# For testing
@export var test_mode: bool = true
@export var scenario_to_test: Scenarios

# Needs refactoring
# var gamemode: GamemodeBase = null
# var computer: ComputerBase = null
# var modifiers: Array[ModifierBase] = []
# var challenge: ChallengeBase = null
# var tasks_completed: int = 0

var game_stats: GameStats
var game_over: bool = false

func _ready() -> void:
	if test_mode: _start_game()

func on_screen_change(information: Dictionary) -> void:
	if information.get("restart"):
		_start_game()
		
		return
	
	# Save no information for now until they are reworked
	# gamemode = information.get("gamemode_resource")
	# modifiers = information.get("modifier_resource", [])
	# computer = information.get("computer_resource")
	# challenge = information.get("challenge", null)

	_start_game()

func _start_game() -> void:
	game_stats = GameStats.new()
	game_over = false
	# tasks_completed = 0
	
	var card_pool: Array[CardBase] = ContentManager.cards.values().duplicate_deep()

	game_stats.player_state.setup(card_pool)
	game_stats.computer_state.setup(card_pool)
	
	# Modifiers need to be refactored
	# for modifier in modifiers:
		# modifier.setup()
		# for change: StatChange in modifier.starting_stat_changes:
			# game_stats.apply_stat_change(change)

	# Gamemodes need to be refactored
	# if gamemode:
	# 	gamemode.apply_stats_edit(game_stats)

	_start_round()

func _start_round() -> void:
	# Decay Overshield
	if game_stats.rounds_played >= 1:
		game_stats.player_state.decay_overshield()
		game_stats.computer_state.decay_overshield()

	game_stats.reset_round()

	# Modifiers need to be refactored
	# for modifier in modifiers:
	# 	if modifier.applied: continue
	
	# 	modifier.check_rules_and_apply(game_stats, ModifierBase.ApplyAt.ROUND_START)
	
	# Test stuff
	if test_mode:
		var test: Dictionary
		
		if scenario_to_test == Scenarios.RANDOMISE:
			test = _get_test_scenerio(randi_range(0, 5))
		else:
			test = _get_test_scenerio()
		
		game_stats.house_suit = test["house_suit"]
		
		var p_move = ChosenCards.from_raw(test["p_suit"], test["p_weight"])
		var a_move = ChosenCards.from_raw(test["a_suit"], test["a_weight"])

		submit_moves(p_move, a_move)

func submit_moves(p_move: ChosenCards, a_move: ChosenCards) -> void:
	game_stats.player_turn_move = p_move
	game_stats.computer_turn_move = a_move

	game_stats.player_move = CardBase.Suit.keys()[p_move.get_effective_suit()].to_lower()
	game_stats.computer_move = CardBase.Suit.keys()[a_move.get_effective_suit()].to_lower()

	# Special Cards
	# if p_move.special_card:
	# 	for effect in p_move.special_card.special_effects:
	# 		effect.apply(game_stats)
	
	# if a_move.special_card:
	# 	for effect in a_move.special_card.special_effects:
	# 		effect.apply(game_stats)

	# Remove played cards
	game_stats.player_state.consume_played_cards(p_move)
	game_stats.computer_state.consume_played_cards(a_move)

	_end_round()

func _end_round() -> void:
	var resolution: Dictionary = _evaluate_round(
		game_stats.house_suit,
		game_stats.player_turn_move,
		game_stats.computer_turn_move
	)
	
	game_stats.outcome = resolution["outcome"]
	game_stats.last_scenario = resolution["scenario"]

	# for modifier in modifiers:
	# 	if modifier.applied:
	# 		continue
	# 	modifier.check_rules_and_apply(game_stats, ModifierBase.ApplyAt.ROUND_END)

	_apply_points(resolution)
	game_stats.record_round_stats()

	_post_round_effects()
	game_stats.advance_house_suit()

	print("--------------------------------------------------")
	print("Summary > " + game_stats.last_round_summary)
	print("Banks > Player: %d (Def: %d, OS: %d) | AI: %d (Def: %d, OS: %d) | House: %d" % [
		game_stats.player_state.bank, game_stats.player_state.defense, game_stats.player_state.overshield,
		game_stats.computer_state.bank, game_stats.computer_state.defense, game_stats.computer_state.overshield,
		game_stats.house_bank
	])
	print("--------------------------------------------------")

	round_resolved.emit(game_stats.outcome, game_stats.last_scenario, game_stats.last_round_summary)
	
	# Gamemode would then check if the game is over

func _evaluate_round(house: CardBase.Suit, p_move: ChosenCards, a_move: ChosenCards) -> Dictionary:
	# p: Player
	# a: AI
	# w: Win
	# l: Loss
	
	var p_suit: CardBase.Suit = p_move.get_effective_suit()
	var a_suit: CardBase.Suit = a_move.get_effective_suit()
	var p_weight: int = p_move.get_total_weight()
	var a_weight: int = a_move.get_total_weight()

	var p_honest: bool = GameStats.is_honest_move(p_suit, house)
	var a_honest: bool = GameStats.is_honest_move(a_suit, house)

	var p_beats_a: bool = GameStats.does_suit_beat(p_suit, a_suit)
	var a_beats_p: bool = GameStats.does_suit_beat(a_suit, p_suit)

	# Scenario D
	if not p_honest and not a_honest:
		return {
			"outcome": GameStats.RoundOutcome.DRAW,
			"scenario": GameStats.ResolutionScenario.SCENARIO_D_DOUBLE_SNIPE_PENALTY,
			"w_weight": 0,
			"l_weight": 0
		}

	if p_honest and a_honest:
		# Scenarios A & B
		if p_beats_a or a_beats_p:
			var p_won: bool = p_beats_a
			
			var w_weight: int = p_weight if p_won else a_weight
			var l_weight: int = a_weight if p_won else p_weight
			
			var scenario = (
				GameStats.ResolutionScenario.SCENARIO_B_HONEST_WIN_POS_WEIGHT
				if (w_weight - l_weight) > 0
				else GameStats.ResolutionScenario.SCENARIO_A_HONEST_WIN_NEG_WEIGHT
			)
			return {
				"outcome": GameStats.RoundOutcome.WIN if p_won else GameStats.RoundOutcome.LOSS,
				"scenario": scenario,
				"w_weight": w_weight,
				"l_weight": l_weight
			}
		else:
			# Scenario G
			if p_weight == a_weight:
				return {
					"outcome": GameStats.RoundOutcome.DRAW,
					"scenario": GameStats.ResolutionScenario.SCENARIO_G_HONEST_EXACT_TIE,
					"w_weight": p_weight,
					"l_weight": a_weight
				}
			else:
				# Scenario E				
				return {
					"outcome": GameStats.RoundOutcome.WIN if p_weight > a_weight else GameStats.RoundOutcome.LOSS,
					"scenario": GameStats.ResolutionScenario.SCENARIO_E_HONEST_SAME_SUIT_WEIGHT_WIN,
					"w_weight": maxi(p_weight, a_weight),
					"l_weight": mini(p_weight, a_weight)
				}
	
	# Sniping
	# Scenarios C & F
	var honest_is_player: bool = p_honest
	var snipe_beats_honest: bool = a_beats_p if honest_is_player else p_beats_a

	if snipe_beats_honest:
		var p_won_snipe: bool = not honest_is_player
		
		return {
			"outcome": GameStats.RoundOutcome.WIN if p_won_snipe else GameStats.RoundOutcome.LOSS,
			"scenario": GameStats.ResolutionScenario.SCENARIO_C_SNIPE_SUCCESS,
			"w_weight": p_weight if p_won_snipe else a_weight,
			"l_weight": a_weight if p_won_snipe else p_weight
		}
	else:		
		return {
			"outcome": GameStats.RoundOutcome.WIN if honest_is_player else GameStats.RoundOutcome.LOSS,
			"scenario": GameStats.ResolutionScenario.SCENARIO_F_SNIPE_FAILED_DEFENSE_IGNORED,
			"w_weight": p_weight if honest_is_player else a_weight,
			"l_weight": a_weight if honest_is_player else p_weight
		}

func _apply_points(resolution) -> void:	
	if game_stats.outcome == GameStats.RoundOutcome.DISCARD:
		game_stats.last_round_summary = "Round discarded."
		return

	var winner_is_player: bool = (game_stats.outcome == GameStats.RoundOutcome.WIN)

	var winner_state: PlayerState = game_stats.player_state if winner_is_player else game_stats.computer_state
	var loser_state: PlayerState = game_stats.computer_state if winner_is_player else game_stats.player_state

	var weight_diff: int = resolution["w_weight"] - resolution["l_weight"]
	
	var house_bank: int = game_stats.house_bank

	match game_stats.outcome:
		GameStats.RoundOutcome.WIN:
			game_stats.wins += 1
			game_stats.current_streak += 1
			game_stats.best_streak = maxi(game_stats.best_streak, game_stats.current_streak)
		GameStats.RoundOutcome.LOSS:
			game_stats.losses += 1
			game_stats.current_streak = 0
		GameStats.RoundOutcome.DRAW:
			game_stats.draws += 1

	match game_stats.last_scenario:
		GameStats.ResolutionScenario.SCENARIO_A_HONEST_WIN_NEG_WEIGHT:
			game_stats.house_bank = 0
			winner_state.bank += game_stats.house_bank
			game_stats.last_round_summary = "Scenario A: Winner gets %d from House. Loser loses 0 (weight diff %d)." % [house_bank, weight_diff]

		GameStats.ResolutionScenario.SCENARIO_B_HONEST_WIN_POS_WEIGHT:
			game_stats.house_bank = 0
			var stolen: int = loser_state.take_bank_damage(weight_diff, false)
			winner_state.bank += (house_bank + stolen)
			game_stats.last_round_summary = "Scenario B: Winner gets %d from House and %d from Loser." % [house_bank, stolen]

		GameStats.ResolutionScenario.SCENARIO_C_SNIPE_SUCCESS:
			var snipe_bonus: int = ceili(float(maxi(0, weight_diff)) / 2.0)
			var stolen: int = loser_state.take_bank_damage(1 + snipe_bonus, false)
			winner_state.bank += stolen
			game_stats.last_round_summary = "Scenario C: Sniper steals %d (1 base + halved weight) from Loser. House untouched." % [stolen, snipe_bonus]

		GameStats.ResolutionScenario.SCENARIO_D_DOUBLE_SNIPE_PENALTY:
			var p_lost: int = mini(game_stats.player_state.bank, 2)
			var a_lost: int = mini(game_stats.computer_state.bank, 2)
			game_stats.player_state.bank -= p_lost
			game_stats.computer_state.bank -= a_lost
			game_stats.house_bank += (p_lost + a_lost)
			game_stats.last_round_summary = "Scenario D: Both lose 2 points due to Sniping. %d goes to the House." % (p_lost + a_lost)

		GameStats.ResolutionScenario.SCENARIO_E_HONEST_SAME_SUIT_WEIGHT_WIN:
			var stolen: int = loser_state.take_bank_damage(weight_diff, false)
			winner_state.bank += stolen
			game_stats.last_round_summary = "Scenario E: Same suit. Higher weight steals %d from Loser. House untouched." % stolen

		GameStats.ResolutionScenario.SCENARIO_F_SNIPE_FAILED_DEFENSE_IGNORED:
			var stolen: int = loser_state.take_bank_damage(1, true)
			winner_state.bank += stolen
			game_stats.last_round_summary = "Scenario F: Failed Snipe. Honest player takes %d from Sniper, ignoring Sniper's defense." % stolen

		GameStats.ResolutionScenario.SCENARIO_G_HONEST_EXACT_TIE:
			game_stats.player_state.defense += 1
			game_stats.computer_state.defense += 1
			game_stats.house_bank += 1
			game_stats.last_round_summary = "Scenario G: Honest Tie. Both gain +1 Defense, +1 point added to House."

func _post_round_effects() -> void:
	if game_stats.outcome == GameStats.RoundOutcome.LOSS:
		loser_must_tutor_card.emit(true, game_stats.player_state.hand.size() >= PlayerState.MAX_HAND_SIZE)
	elif game_stats.outcome == GameStats.RoundOutcome.WIN:
		game_stats.computer_state.tutor_card_on_loss(0, 0)
		loser_must_tutor_card.emit(false, game_stats.computer_state.hand.size() >= PlayerState.MAX_HAND_SIZE)

	if not test_mode:
		if game_stats.player_state.hand.is_empty() and not game_stats.player_state.deck.is_empty():
			empty_hand_reward_requested.emit(true)
		if game_stats.computer_state.hand.is_empty() and not game_stats.computer_state.deck.is_empty():
			game_stats.computer_state.claim_empty_hand_reward(true)
			empty_hand_reward_requested.emit(false)

func _get_test_scenerio(index: int = scenario_to_test) -> Dictionary:
	var house = CardBase.Suit.ROCK
	
	match index:
		# Scenario A: Light Paper vs Heavy Spock.
		# Expected Result: Negative weight diff, no points except House Bank (1 point)
		0:
			return {"house_suit": house, "p_suit": CardBase.Suit.PAPER, "p_weight": 1, "a_suit": CardBase.Suit.SPOCK, "a_weight": 4}
		# Scenario B: Heavy Paper vs Light Spock
		# Expected Result: Positive weight diff, player gets 4 points (3 from weight diff, 1 from House)
		1:
			return {"house_suit": house, "p_suit": CardBase.Suit.PAPER, "p_weight": 4, "a_suit": CardBase.Suit.SPOCK, "a_weight": 1}
		# Scenario C: Light Paper vs Colossal Scissors
		# Expected Result: +3 to opponent, halve rate due to sniping, House Bank at 1 point
		2:
			return {"house_suit": house, "p_suit": CardBase.Suit.PAPER, "p_weight": 1, "a_suit": CardBase.Suit.SCISSORS, "a_weight": 5}
		# Scenario D: Regular Scissors vs Regular Scissors
		# Expected Result: -2 to both, goes into House Bank
		3:
			return {"house_suit": house, "p_suit": CardBase.Suit.SCISSORS, "p_weight": 2, "a_suit": CardBase.Suit.SCISSORS, "a_weight": 2}
		# Scenario E: Regular Spock vs Moderate Spock
		4:
			return {"house_suit": house, "p_suit": CardBase.Suit.SPOCK, "p_weight": 2, "a_suit": CardBase.Suit.SPOCK, "a_weight": 3}
		# Scenario F: Light Paper vs Colossal Rock
		# Expected Result: -1 to loser, 0 Defense
		5:
			return {"house_suit": house, "p_suit": CardBase.Suit.PAPER, "p_weight": 1, "a_suit": CardBase.Suit.ROCK, "a_weight": 5}
		# Scenario G: Moderate Paper vs Moderate Paper
		# Expected Result: +1 Defense, +1 to House Bank
		_:
			return {"house_suit": house, "p_suit": CardBase.Suit.PAPER, "p_weight": 3, "a_suit": CardBase.Suit.PAPER, "a_weight": 3}
