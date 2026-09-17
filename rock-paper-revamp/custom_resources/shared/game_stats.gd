class_name GameStats
extends RefCounted

var player_move: String = ""
var computer_move: String = ""

var player_points: int = 0
var computer_points: int = 0

var wins: int = 0
var losses: int = 0
var draws: int = 0

var current_streak: int = 0
var best_streak: int = 0

var rounds_played: int = 0
var total_rounds: int = -1
var timer_length: float = 5.0
var max_points: int = -1

var previous_outcome: Array[String] = []
var player_history: Array[String] = []
var computer_history: Array[String] = []

var played_moves: Dictionary = {
	"rock": 0,
	"paper": 0,
	"scissors": 0,
}

func record_outcome(outcome: String) -> void:
	rounds_played += 1
	previous_outcome.append(outcome)
	
	if player_move in played_moves:
		played_moves[player_move] += 1
		player_history.append(player_move)
	else:
		player_history.append("none")
		
	computer_history.append(computer_move)

	match outcome:
		"win":
			wins += 1
			player_points += 1
			current_streak += 1
			best_streak = maxi(best_streak, current_streak)
		"loss":
			losses += 1
			computer_points += 1
			current_streak = 0
		"draw":
			draws += 1

func apply_stat_change(stat_name: String, operation: int, value: Variant):
	var current = get(stat_name)
	if current == null:
		push_warning("Stat not found on GameStats: ", stat_name)
		return
		
	match operation:
		StatChange.Operation.ADD:
			set(stat_name, current + value)
		StatChange.Operation.SUBTRACT:
			set(stat_name, current - value)
		StatChange.Operation.DIVIDE:
			set(stat_name, current / value)
		StatChange.Operation.MULTIPLY:
			set(stat_name, current * value)
		StatChange.Operation.SET:
			set(stat_name, value)
