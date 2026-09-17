extends ModifierTrigger
class_name TriggerChance

## The chance needed for the trigger to be met.
@export_range(0.0, 1.0, 0.01) var probability: float = 0.0

func is_met(_game_stats: GameStats) -> bool:
	return randf() <= probability
