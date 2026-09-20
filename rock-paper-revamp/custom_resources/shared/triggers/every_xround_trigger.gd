extends GameplayTrigger
class_name EveryXRoundTrigger

## The number of rounds this happens at.
@export var round_interval: int = 3

func is_met(game_stats: GameStats) -> bool:
	return game_stats.rounds_played % round_interval == 0
