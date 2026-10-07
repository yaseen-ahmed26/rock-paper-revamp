class_name GameStats
extends RefCounted

enum StatNames {
	PLAYER_POINTS,
	COMPUTER_POINTS,
	CURRENT_STREAK,
	BEST_STREAK,
	TOTAL_ROUNDS,
	TIMER_LENGTH,
	MAX_POINTS,
	BASE_POINTS_ON_WIN,
	BONUS_POINTS_ON_WIN,
	BASE_POINTS_ON_LOSS,
	BONUS_POINTS_ON_LOSS,
	GLOBAL_POINT_MULTIPLIER,
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

const DEFAULT_MOVES: Array[String] = ["rock", "paper", "scissors"]

var player_move: String = ""
var computer_move: String = ""
var outcome: RoundOutcome

var player_points: float = 0.0
var computer_points: float = 0.0

var wins: int = 0
var losses: int = 0
var draws: int = 0

var current_streak: int = 0
var best_streak: int = 0

var rounds_played: int = 0
var total_rounds: int = -1
var timer_length: float = 5.0
var max_points: int = -1

var base_points_on_win: float = 1.0
var base_points_on_loss: float = 1.0

var bonus_points_on_win: float = 0
var bonus_points_on_loss: float = 0

var global_point_multiplier: float = 1.0

var previous_outcome: Array[String] = []
var player_history: Array[String] = []
var computer_history: Array[String] = []

var played_moves: Dictionary = {
	"rock": 0,
	"paper": 0,
	"scissors": 0,
}

var outcome_multiplier: int = 1

var btn_stats: Dictionary[String, MoveStat] = {}

var round_activated_modifiers: Array[ModifierBase.ID] = []
var modifier_usage_count: Dictionary[ModifierBase.ID, int] = {}

func _init() -> void:
	reset_btn_state()

func reset_btn_state():
	btn_stats.clear()
	
	for move in DEFAULT_MOVES:
		btn_stats[move] = MoveStat.new(move.capitalize(), move, false, true)

func add_used_modifier(modifier_id: ModifierBase.ID):
	if not round_activated_modifiers.has(modifier_id):
		round_activated_modifiers.append(modifier_id)

	if not modifier_usage_count.has(modifier_id):
		modifier_usage_count[modifier_id] = 1
	else:
		modifier_usage_count[modifier_id] += 1

func apply_round_outcome():
	if outcome == RoundOutcome.DISCARD: return
	
	var move_bonus: float = 0.0
	
	if not player_move.is_empty():
		move_bonus = btn_stats[player_move].point_bonus

	for i in outcome_multiplier:
		match outcome:
			RoundOutcome.WIN:
				wins += 1
				player_points += ((base_points_on_win + bonus_points_on_win + move_bonus) * global_point_multiplier) 
				current_streak += 1
				best_streak = maxi(best_streak, current_streak)
			RoundOutcome.LOSS:
				losses += 1
				computer_points += ((base_points_on_loss + bonus_points_on_loss) * global_point_multiplier) 
				current_streak = 0
			RoundOutcome.DRAW:
				draws += 1

func record_round_stats() -> void:
	previous_outcome.append(RoundOutcome.keys()[outcome])
	
	if player_move in played_moves:
		played_moves[player_move] += 1
		player_history.append(player_move)
	else:
		player_history.append("none")
		
	computer_history.append(computer_move)

func apply_stat_change(stat_change: StatChange):
	var lower_stat = get_lower_stat(stat_change.target_stat)
	var current = get(lower_stat)
	
	if current == null:
		push_warning("(GameStats) '%s' is not a valid stat" % stat_change.target_stat)
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

	print("(GameStats) '%s' has been edited" % lower_stat)

func reset_round():
	player_move = ""
	computer_move = ""
	outcome = RoundOutcome.CLEARED
	rounds_played += 1
	round_activated_modifiers.clear()
	
	reset_btn_state()

func get_lower_stat(stat_name):
	return StatNames.keys()[stat_name].to_lower()

func get_points_on_win():
	var move_bonus: float = btn_stats[player_move].point_bonus
	return ((base_points_on_win + bonus_points_on_win + move_bonus) * global_point_multiplier) 

func get_points_on_loss():
	return ((base_points_on_loss + bonus_points_on_loss) * global_point_multiplier) 
