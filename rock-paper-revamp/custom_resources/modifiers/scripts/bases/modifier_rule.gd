extends Resource
class_name ModifierRule

@export_group("Arrays")
## The triggers required for this rule to be met.
@export var triggers: Array[GameplayTrigger]
## The effects applied when this rule has been met.
@export var effects: Array[ModifierEffect]

func check_and_apply(stats: GameStats):
	var triggers_met: int = 0
	
	for trigger in triggers:
		var met: bool = trigger.is_met(stats)
		if met: triggers_met += 1
		
	if triggers_met == triggers.size():
		for effect in effects:
			effect.apply(stats)
	else:
		return false
	
	return true
