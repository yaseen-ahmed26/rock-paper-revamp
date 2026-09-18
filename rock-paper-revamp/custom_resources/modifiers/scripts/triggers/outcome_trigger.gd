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
			
	if game_stats.outcome == GameStats.RoundOutcome.WIN and required_outcome == RequiredOutcome.WIN:
		return true
	elif game_stats.outcome == GameStats.RoundOutcome.DRAW and required_outcome == RequiredOutcome.DRAW:
		return true
	elif game_stats.outcome == GameStats.RoundOutcome.LOSS and required_outcome == RequiredOutcome.LOSS:
		return true
		
	return false
