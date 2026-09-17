extends Node

"""
1. Loop through all Modifiers and apply them
2. Apply some Modifiers at some points
	- Round Start
	- Round End
	- Every Second
"""

func apply_initial_modifiers(stats: GameStats, modifiers: Array[ModifierBase]):
	for modifier in modifiers:
		if modifier.stats_to_edit.is_empty(): continue
		
		for change: StatChange in modifier.stats_to_edit_start:
			stats.apply_stat_change(change.target_stat, change.operation, change.value)

func _parse_custom_modifier(stats: GameStats, modifier: ModifierBase):
	pass

func use_modifiers(stats: GameStats, modifiers: Array[ModifierBase], timing: ModifierBase.ApplyAt):
	for modifier in modifiers:
		if timing != modifier.timing: continue
		
		var triggers_met: int = 0
		
		for trigger in modifier.triggers:
			var met: bool = trigger.is_met(stats)
		
			if met: triggers_met += 1
			
		if triggers_met == modifier.triggers.size():
			print("All triggers met")
