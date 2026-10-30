extends Resource
class_name ContractSubtask

## When to check for this subtask's completion.
@export var timing: ModifierBase.ApplyAt
## The Triggers needed for this task.
@export var triggers: Array[GameplayTrigger]
## The cosmetic text to display on UI.
@export var cosmetic_text: String
## If true, then all Triggers MUST evaluate to false to be considered complete.
@export var invert: bool = false
## How many times this subtask needs to be completed to considered true. Set to 1 for only 1 time needed to be completed.
@export var completion_amount: int = 1

func check_completion(game_stats: GameStats, round_timing: ModifierBase.ApplyAt):
	if timing != round_timing:
		return false
	
	var triggers_met: int = 0
	
	for trigger in triggers:
		if trigger.is_met(game_stats):
			triggers_met += 1
		else:
			if invert:
				triggers_met += 1
	
	if triggers_met == triggers.size():
		return true
		
	return false
