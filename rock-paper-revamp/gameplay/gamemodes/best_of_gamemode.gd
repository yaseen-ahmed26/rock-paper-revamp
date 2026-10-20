extends GamemodeBase
class_name BestOfGamemode

@export var total_rounds: int = 5

func get_customisable_settings() -> Dictionary:
	return {
		"total_rounds": {
			"label": "Total Rounds",
			"min": 1,
			"max": 25,
			"step": 2
		}
	}

func apply_stats_edit(game_stats: GameStats):
	game_stats.total_rounds = total_rounds

func is_game_over(game_stats: GameStats):
	return game_stats.rounds_played == total_rounds
