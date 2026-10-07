extends GamemodeBase
class_name RaceToGamemode

@export var starting_points: float = 3.0
@export var total_rounds: int = 7

func get_customisable_settings():
	return {
		"starting_points": {
			"label": "Starting Points", 
			"min": 2, 
			"max": 20, 
			"step": 1 
		},
		"total_rounds": {
			"label": "Total Rounds", 
			"min": -1, 
			"max": 15, 
			"step": 1 
		},
	}

func apply_stats_edit(game_stats: GameStats):
	game_stats.computer_points = starting_points
	game_stats.player_points = starting_points
	game_stats.total_rounds = total_rounds if total_rounds != 0 else 1

func is_game_over(game_stats: GameStats):
	return game_stats.player_points == 0 or game_stats.computer_points == 0 or game_stats.rounds_played == total_rounds	
