extends GamemodeBase
class_name ComebackGamemode

@export var ai_starting_points: float = 3.0
@export var total_rounds: int = 8.0

func apply_stats_edit(game_stats: GameStats):
	game_stats.computer_points = ai_starting_points
	game_stats.total_rounds = total_rounds

func is_game_over(game_stats: GameStats):
	return game_stats.rounds_played == total_rounds	
