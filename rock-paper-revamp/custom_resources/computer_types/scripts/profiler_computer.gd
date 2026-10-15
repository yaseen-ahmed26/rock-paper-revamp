extends ComputerBase
class_name ProfilerComputer

"""
What the AI does:
1. Looks at locked moves from active Modifiers.
2. Tracks what move the player likes to play AFTER their previous move.
3. Enters a special mode to confuse the player if they get on a win streak.
"""

const COUNTERS: Dictionary = {
	"rock": "paper",
	"paper": "scissors",
	"scissors": "rock"
}

const BEATS: Dictionary = {
	"rock": "scissors",
	"paper": "rock",
	"scissors": "paper"
}

func pick_move(stats: GameStats) -> String:
	if stats.rounds_played <= 1 or stats.player_history.is_empty():
		return GameStats.DEFAULT_MOVES.pick_random()

	var lock_exploit: String = _get_locked_move_exploit(stats)
	
	if not lock_exploit.is_empty():
		return lock_exploit

	var predicted_move: String = _predict_next_from_history(stats)

	if predicted_move.is_empty():
		predicted_move = _predict_from_last_round(stats)

	if not COUNTERS.has(predicted_move):
		return GameStats.DEFAULT_MOVES.pick_random()

	var chosen_move: String = COUNTERS[predicted_move]

	if stats.current_streak >= 2:
		chosen_move = COUNTERS[COUNTERS[chosen_move]]

	return chosen_move

func _get_locked_move_exploit(stats: GameStats) -> String:
	var unlocked_moves: Array[String] = []
	
	for move in GameStats.DEFAULT_MOVES:
		if stats.btn_stats.has(move) and not stats.btn_stats[move].lock:
			unlocked_moves.append(move)

	if unlocked_moves.size() == 2:
		var move_a: String = unlocked_moves[0]
		var move_b: String = unlocked_moves[1]
		
		if BEATS[move_a] == move_b:
			return move_a
		else:
			return move_b
			
	return ""

func _predict_next_from_history(stats: GameStats) -> String:
	var history: Array[String] = stats.player_history
	if history.size() < 3: return ""
		
	var last_move: String = history[-1]
	if last_move == "none": return ""
		
	var follow_up_counts: Dictionary = {"rock": 0, "paper": 0, "scissors": 0}
	
	for i in range(history.size() - 1):
		if history[i] == last_move:
			var next_move: String = history[i + 1]
			
			if follow_up_counts.has(next_move):
				follow_up_counts[next_move] += 1
				
	var best_guess: String = ""
	var highest_count: int = 0
	var is_tied: bool = false
	
	for move in follow_up_counts:
		var count: int = follow_up_counts[move]
		
		if count > highest_count:
			highest_count = count
			best_guess = move
			is_tied = false
		elif count == highest_count and count > 0:
			is_tied = true
			
	if is_tied or highest_count == 0: return ""	
	
	return best_guess

func _predict_from_last_round(stats: GameStats) -> String:
	if stats.previous_outcome.is_empty(): return ""
		
	var last_outcome: String = stats.previous_outcome[-1]
	var player_last: String = stats.player_history[-1]
	var ai_last: String = stats.computer_history[-1]
	
	match last_outcome:
		"WIN":
			return player_last
		"LOSS":
			return COUNTERS.get(ai_last, "")
		_:
			return ""
