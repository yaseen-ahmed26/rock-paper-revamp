extends GameplayEffect
class_name DiscardOutcomeEffect

func apply(game_stats: GameStats):
	game_stats.outcome = GameStats.RoundOutcome.DISCARD
