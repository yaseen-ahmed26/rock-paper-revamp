extends ModifierTrigger
class_name OutcomeTrigger

enum RequiredOutcome { 
	WIN, 
	LOSS, 
	DRAW, 
	ANY 
}

## The outcome needed to make this trigger met.
@export var required_outcome: RequiredOutcome = RequiredOutcome.ANY

func is_met(game_stats: GameStats) -> bool:
	if required_outcome == RequiredOutcome.ANY:
		return true
			
	match game_stats.outcome:
		RequiredOutcome.WIN: return game_stats.outcome == "win"
		RequiredOutcome.LOSS: return game_stats.outcome == "loss"
		RequiredOutcome.DRAW: return game_stats.outcome == "draw"
		
	return false
