extends Node

const DEFAULT_GAME_STATS: Dictionary = {
	"player_move": "",
	"ai_move": "",
	
	"player_points": 0,
	"ai_points": 0,
	
	"player_wins": 0,
	"player_losses": 0,
	"draws": 0,
	
	"current_streak": 0,
	"best_streak": 0,
	
	"rounds_played": 0,
	"total_rounds": -1
}

func _apply_stat_edit(stats: Dictionary, stat_change: StatChange):	
	if not stats.has(stat_change.target_stat):
		push_warning("No stat found: ", stat_change.target_stat)
		return stats
	
	match stat_change.operation:
		StatChange.Operation.ADD:
			stats[stat_change.target_stat] += stat_change.value
		StatChange.Operation.SUBTRACT:
			stats[stat_change.target_stat] -= stat_change.value
		StatChange.Operation.DIVIDE:
			stats[stat_change.target_stat] /= stat_change.value
		StatChange.Operation.MULTIPLY:
			stats[stat_change.target_stat] *= stat_change.value
		StatChange.Operation.SET:
			stats[stat_change.target_stat] = stat_change.value
		
	return stats

func setup_game(gamemode: GamemodeBase):
	var stats = DEFAULT_GAME_STATS.duplicate_deep()

	if not gamemode.stats_to_edit.is_empty():
		for change in gamemode.stats_to_edit:
			_apply_stat_edit(stats, change)

	return stats
