extends Node

"""
1. Loop through all Modifiers and apply them
2. Apply some Modifiers at some points
	- Round Start
	- Round End
	- Every Second
"""

func apply_initial_modifiers(stats: GameStats, modifier: ModifierBase):
	if not modifier.apply_on_start: return
	
	for change: StatChange in modifier.stats_to_edit_start:
		stats.apply_stat_change(change.target_stat, change.operation, change.value)
