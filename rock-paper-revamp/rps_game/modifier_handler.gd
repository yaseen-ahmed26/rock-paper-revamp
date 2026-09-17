extends Node

"""
1. Loop through all Modifiers and apply them
2. Apply some Modifiers at some points
	- Round Start
	- Round End
	- Every Second
"""

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

func apply_modifiers(stats: Dictionary, modifier: ModifierBase):
	if modifier.apply_on_start:
		for change: StatChange in modifier.stats_to_edit_start:
			if not stats.has(change.target_stat):
				push_warning("No stat found '%s' for Modifier %s to apply on game start" % [change.target_stat, modifier.display_name])
				continue
			
			match change.operation:
				StatChange.Operation.ADD:
					stats[change.target_stat] += change.value
				StatChange.Operation.SUBTRACT:
					stats[change.target_stat] -= change.value
				StatChange.Operation.DIVIDE:
					stats[change.target_stat] /= change.value
				StatChange.Operation.MULTIPLY:
					stats[change.target_stat] *= change.value
				StatChange.Operation.SET:
					stats[change.target_stat] = change.value
		
		return stats
	else:
		return stats
