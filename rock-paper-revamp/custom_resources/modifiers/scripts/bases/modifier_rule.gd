extends Resource
class_name ModifierRule

@export_group("Arrays")
## The triggers required for this rule to be met.
@export var triggers: Array[GameplayTrigger]
## The effects applied when this rule has been met.
@export var effects: Array[ModifierEffect]
