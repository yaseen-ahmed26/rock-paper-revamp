extends ComputerBase
class_name StatisticsComputer

"""
Plays the counter to the player's most used
move
"""

const COUNTERS: Dictionary = {
	"rock": "paper",
	"paper": "scissors",
	"scissors": "rock"
}

func pick_move(stats: GameStats):
	if stats.rounds_played == 1:
		return GameStats.DEFAULT_MOVES.pick_random()

	var most_played_move: String = ""
	var highest_count: int = -1
	var is_tied: bool = false

	for move in stats.played_moves:
		var count: int = stats.played_moves[move]
		
		if count > highest_count:
			highest_count = count
			most_played_move = move
			is_tied = false
		elif count == highest_count:
			is_tied = true

	if is_tied or most_played_move.is_empty():
		return GameStats.DEFAULT_MOVES.pick_random()

	return COUNTERS[most_played_move]
