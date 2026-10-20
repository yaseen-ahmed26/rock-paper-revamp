extends Resource
class_name ModifierRule

## The triggers required for this rule to be met.
@export var triggers: Array[GameplayTrigger]
## The effects applied when this rule has been met.
@export var effects: Array[ModifierEffect]

func check_and_apply(stats: GameStats, internal_state: ModifierInternal):
	var triggers_met: int = 0
	
	for trigger in triggers:
		var met: bool 
		
		if trigger is InternalModifierTrigger:
			met = trigger.is_met(internal_state) if internal_state else false
		else:
			met = trigger.is_met(stats)
		if met: triggers_met += 1
		
	if triggers_met == triggers.size():
		for effect in effects:
			if effect is InternalModifierEffect:
				effect.apply(internal_state)
			else:
				effect.apply(stats)
	else:
		return false
	
	return true
