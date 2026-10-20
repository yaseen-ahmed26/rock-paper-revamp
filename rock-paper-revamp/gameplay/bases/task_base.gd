extends DescribedBase
class_name TaskBase

enum Timing {
	ROUND_END,
	MATCH_END
}

@export_group("General")
## When to check if this Task has been completed
@export var timing: Timing
## The triggers for this Task to be completed
@export var triggers: Array[GameplayTrigger]

@export_group("Flags")
## If true, then all triggers need return false for the task to be completed.
@export var invert_triggers: bool = false

func check_completion(game_stats: GameStats):
	if triggers.is_empty():
		print("No triggers set for Task '%s'" % id)
		return false
	
	var triggers_met: int = 0
	
	for trigger: GameplayTrigger in triggers:
		if trigger.is_met(game_stats):			
			triggers_met += 1
	
	if invert_triggers:
		return triggers_met == 0
	
	return triggers_met == triggers.size()
