extends Node

"""
Round End Priority:
	- Force Max Rounds Played
	- Stat Threshold Met
	- Custom Logic
"""

func create_game_stats(gamemode: GamemodeBase):
	var game_stats: GameStats = GameStats.new()

	if not gamemode.stats_to_edit.is_empty():
		for change: StatChange in gamemode.stats_to_edit:
			game_stats.apply_stat_change(change)

	return game_stats

func check_round_end(stats: GameStats, gamemode: GamemodeBase):
	if gamemode.ignore_end_condition: return false
	
	if gamemode.end_at_total_rounds:
		if stats.total_rounds == -1:
			print("Gamemode '%s' cannot force end at max rounds played when it is set to -1" % gamemode.display_name)
			return false
		
		if stats.rounds_played == stats.total_rounds:
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
				if stats.player_points == stats.max_points or stats.computer_points == stats.max_points:
					return true
				else:
					return false
			_:
				print("%s has 'custom_end_condition' set to True but no custom end condition has been written" % gamemode.display_name)
				return false
