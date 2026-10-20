extends ComputerBase
class_name GambleComputer

"""
- Won last round: play the same move
- Lost last round: play what beats the player's last move
- Draws: pick random
"""

const COUNTERS: Dictionary = {
	"rock": "paper",
	"paper": "scissors",
	"scissors": "rock"
}

func pick_move(stats: GameStats) -> String:
	if stats.rounds_played == 1 or stats.previous_outcome.is_empty():
		return GameStats.DEFAULT_MOVES.pick_random()

	var last_outcome: String = stats.previous_outcome[-1]

	match last_outcome:
		"LOSS":
			return stats.computer_history[-1]
		"WIN":
			var player_last: String = stats.player_history[-1]
			
			if COUNTERS.has(player_last):
				return COUNTERS[player_last]
				
			return GameStats.DEFAULT_MOVES.pick_random()
		_:
			return GameStats.DEFAULT_MOVES.pick_random()
