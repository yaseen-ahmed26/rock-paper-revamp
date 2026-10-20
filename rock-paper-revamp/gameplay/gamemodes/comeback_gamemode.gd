extends GamemodeBase
class_name ComebackGamemode

@export var ai_starting_points: float = 3.0
@export var total_rounds: int = 8

func get_customisable_settings():
	return {
		"ai_starting_points": {
			"label": "AI Starting Lead", 
			"min": 1, 
			"max": 10, 
			"step": 1 
		},
		"total_rounds": { 
			"label": "Total Rounds", 
			"min": 3, 
			"max": 20, 
			"step": 1 
		}
	}

func apply_stats_edit(game_stats: GameStats):
	game_stats.computer_points = ai_starting_points
	game_stats.total_rounds = total_rounds

func is_game_over(game_stats: GameStats):
	return game_stats.rounds_played == total_rounds	
