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

func _parse_custom_modifier(stats: GameStats, modifier: ModifierBase):
	pass

func use_modifiers(stats: GameStats, modifier: ModifierBase, timing: ModifierBase.ApplyAt, outcome: String):
	if timing != modifier.timing: return
	
	print("Modifier Usage")
	
	var conditions_met = 0
	var total_conditions = 0
	
	if modifier.apply_every_x:
		print("'Apply Every X' is true")
		total_conditions += 1
		
		if stats.rounds_played != 0 and int(stats.rounds_played) % modifier.apply_every == 0:
			print("'Apply Every X' condition has been met")
			conditions_met += 1

	if modifier.has_chance:
		print("'Has Chance' is true")
		total_conditions += 1
		
		if randf() <= modifier.chance_to_apply:
			print("'Has Chance' condition has been met")
			conditions_met += 1
			
	if modifier.apply_on_outcome and timing != ModifierBase.ApplyAt.ROUND_START:
		print("'Apply On Outcome' is true")
		total_conditions += 1
		
		if modifier.outcome_needed == outcome:
			print("'Apply On Outcome' condition has been met")
			conditions_met += 1
	
	print("Total Conditions: ", total_conditions)
	print("Conditions Met: ", conditions_met)
	
	if conditions_met == total_conditions:
		print("All Conditions Met, Applying Modifier...")
		if modifier.custom:
			print("Modifier has custom logic")
			_parse_custom_modifier(stats, modifier)
		elif modifier.edit_stats_on_apply:
			print("Modifier is editing stats on apply")
			for change: StatChange in modifier.stats_to_edit_apply:
				print("Change applied to ", change.target_stat)
				stats.apply_stat_change(change.target_stat, change.operation, change.value)
	
	print("------------------------------")
