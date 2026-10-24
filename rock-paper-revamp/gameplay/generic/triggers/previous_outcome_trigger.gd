extends GameplayTrigger
class_name PreviousOutcomeTrigger

## How many rounds to look back
@export var rounds_to_look: int
## What outcome to expect
@export var outcome: GameStats.RoundOutcome

func is_met(game_stats: GameStats):
	if rounds_to_look > game_stats.previous_rounds.size():
		return false
		
	var previous_outcome = game_stats.previous_rounds[rounds_to_look].outcome
	
	return previous_outcome == outcome
