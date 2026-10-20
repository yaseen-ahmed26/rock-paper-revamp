extends GamemodeBase
class_name SurvivalGamemode

func is_game_over(game_stats: GameStats):
	if game_stats.rounds_played == 1:
		return false
		
	return game_stats.current_streak == 0
