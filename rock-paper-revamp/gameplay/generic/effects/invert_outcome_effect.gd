extends GameplayEffect
class_name InvertOutcomeEffect

func apply(game_stats: GameStats):
	if game_stats.outcome == GameStats.RoundOutcome.WIN:
		game_stats.outcome = GameStats.RoundOutcome.LOSS
	elif game_stats.outcome == GameStats.RoundOutcome.LOSS:
		game_stats.outcome = GameStats.RoundOutcome.WIN
