extends GameplayEffect
class_name ForceOutcomeEffect

@export var new_outcome: GameStats.RoundOutcome

func apply(game_stats: GameStats):
	game_stats.outcome = new_outcome if new_outcome != GameStats.RoundOutcome.CLEARED else GameStats.RoundOutcome.DISCARD
