extends Node

"""
Round End Priority:
	- Force Max Rounds Played
	- Stat Threshold Met
	- Custom Logic
"""

const DEFAULT_GAME_STATS: Dictionary = {
	"player_move": "",
	"computer_move": "",
	
	"player_points": 0,
	"computer_points": 0,
	
	"wins": 0,
	"losses": 0,
	"draws": 0,
	
	"current_streak": 0,
	"best_streak": 0,
	
	"rounds_played": 0,
	"total_rounds": -1,
	
	"base_points_on_win": 1,
	"bonus_points_on_win": 0,
	
	"base_points_on_loss": 1,
	"bonus_points_on_loss": 0,
	
	"max_points": -1,
	"global_point_multiplier": 1, 

	"additional_rock_value": 0,
	"additional_paper_value": 0,
	"additional_scissors_value": 0,
	
	"timer_length": 5.0,
	
	"previous_outcome": [],
	"player_history": [],
	"computer_history": [],
	
	"played_moves": {
		"rock": 0,
		"paper": 0,
		"scissors": 0,
	},
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

func check_round_end(stats: Dictionary, gamemode: GamemodeBase):
	if gamemode.ignore_end_condition: return false
	
	if gamemode.end_at_total_rounds:
		if stats.get("total_rounds") == -1:
			print("Gamemode '%s' cannot force end at max rounds played when it is set to -1" % gamemode.display_name)
			return false
		
		if stats.get("rounds_played") == stats.get("total_rounds"):
			return true
		else:
			return false
	elif gamemode.end_at_stat_threhold:
		var thresholds_met: int = 0
		
		for k in gamemode.stat_thresholds.keys():
			var v = gamemode.stat_thresholds[k]
			
			if stats.get(k) == v: thresholds_met += 1
			
		if thresholds_met == gamemode.stat_thresholds.size():
			return true
		else:
			return false
	elif gamemode.custom_end_condition:
		match gamemode.id:
			GamemodeBase.ID.FIRST_TO:
				if stats.get("player_points") == stats.get("max_points") or stats.get("computer_points") == stats.get("max_points"):
					return true
				else:
					return false
			_:
				print("%s has 'custom_end_condition' set to True but no custom end condition has been written" % gamemode.display_name)
				return false
