extends Resource
class_name TaskBase

enum ID {
	FIRST_TO_GM_1,
	FIRST_TO_GM_2,
	COMEBACK_GM_1,
	COMEBACK_GM_2,
	SURVIVAL_GM_1,
	BEST_OF_GM_1,
	RULE_REVERSAL_MD_1,
	DOUBLE_DOWN_MD_1,
	COPY_CAT_MD_1,
	COPY_CAT_MD_2,
	TAX_TOLL_MD_1
}

enum Timing {
	ROUND_END,
	MATCH_END
}

@export_category("Metadata")
## The unqiue ID for this Task
@export var id: ID
## The name that is displayed on UI
@export var display_name: String
## The description of the Task
@export var description: String
## When to check if this Task has been completed
@export var timing: Timing
## The triggers for this Task to be completed
@export var triggers: Array[GameplayTrigger]

@export_category("Flags")
## If true, then all triggers need return false for the task to be completed.
@export var invert_triggers: bool = false

func check_completion(game_stats: GameStats):
	if triggers.is_empty():
		print("No triggers set for Task '%s'" % ID.keys()[id].to_lower())
		return false
	
	var triggers_met: int = 0
	
	for trigger: GameplayTrigger in triggers:
		if trigger.is_met(game_stats):			
			triggers_met += 1
	
	if invert_triggers:
		return triggers_met == 0
	
	return triggers_met == triggers.size()
