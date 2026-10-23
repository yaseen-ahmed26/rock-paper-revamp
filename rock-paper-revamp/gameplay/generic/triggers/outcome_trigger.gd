extends GameplayTrigger
class_name OutcomeTrigger

enum RequiredOutcome { 
	WIN, 
	LOSS, 
	DRAW 
}

## The outcome needed to make this trigger met.
@export var required_outcome: RequiredOutcome

func is_met(game_stats: GameStats) -> bool:				
	return game_stats.outcome == required_outcome
