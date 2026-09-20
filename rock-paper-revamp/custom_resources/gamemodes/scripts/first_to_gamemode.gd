extends GamemodeBase
class_name FirstToGamemode

@export var point_threshold: float = 3.0

func apply_stats_edit(_game_stats: GameStats):
	pass

func is_game_over(game_stats: GameStats):
	return game_stats.player_points == point_threshold or game_stats.computer_points == point_threshold
