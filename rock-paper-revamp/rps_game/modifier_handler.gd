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
		
		for change: StatChange in modifier.stats_to_edit:
			stats.apply_stat_change(change)

func use_modifiers(stats: GameStats, modifiers: Array[ModifierBase], timing: ModifierBase.ApplyAt):
	if stats.rounds_played == 1: return
	
	var modifiers_to_remove: Array[ModifierBase] = []
	
	for modifier in modifiers:
		if timing != modifier.timing: continue
		
		var triggers_met: int = 0
		
		for trigger in modifier.triggers:
			var met: bool = trigger.is_met(stats)
		
			if met: triggers_met += 1
		
		var apply_modifier: bool = false
		
		if modifier.triggers.size() != 0:
			if modifier.trigger_type == ModifierBase.TriggerType.ALL_REQUIRED:
				apply_modifier = triggers_met == modifier.triggers.size()
			elif modifier.trigger_type == ModifierBase.TriggerType.ANY:
				apply_modifier = triggers_met >= 1 # and modifier.triggers.size() < 1
		else:
			apply_modifier = true
		
		if apply_modifier:
			for effect in modifier.effects:
				effect.apply(stats)

			if modifier.one_shot:
				modifiers_to_remove.append(modifier)

	for modifier in modifiers_to_remove:
		owner.modifiers.erase(modifier)
