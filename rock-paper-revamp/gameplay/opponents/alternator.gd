extends ComputerBase
class_name AlternatorComputer

"""
Plays a random set of moves for 4 rounds, changes on draws
"""

var sequence: Array = GameStats.DEFAULT_MOVES.duplicate_deep()
var sequence_played: int = 0

func pick_move(stats: GameStats):
	if stats.rounds_played == 1 or stats.previous_outcome.is_empty():
		return GameStats.DEFAULT_MOVES.pick_random()

	var last_outcome: String = stats.previous_outcome[-1]
	
	if last_outcome == "DRAW":
		sequence.shuffle()
		return GameStats.DEFAULT_MOVES.pick_random()
	
	if sequence_played == (sequence.size() - 1):
		sequence_played = 0
		
		return sequence[sequence_played]
	else:
		sequence_played += 1
		
		return sequence[sequence_played]
	
