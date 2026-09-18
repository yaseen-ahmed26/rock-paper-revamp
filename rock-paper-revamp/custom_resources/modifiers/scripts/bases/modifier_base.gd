extends Resource
class_name ModifierBase

enum ID {
	TEST_1
}
enum Group {
	UI,
	POINTS,
	OUTCOME,
	MISC
}
enum ApplyAt {
	ROUND_START,
	ROUND_END
}

@export_category("Metadata")
## The unique ID for this Modifier
@export var id: ID
## The name shown on UI
@export var display_name: String
## The description of this Modifier
@export var description: String
## The group this Modifier belongs to, affects the order in which it is applied.
@export var group: Group
## When the Modifier should be applied.
@export var timing: ApplyAt
## If True, only applies the Modifier once, then it is removed from the list.
@export var one_shot: bool = false
## The modifiers to blacklist when this one is selected.
@export var modifier_blacklist: Array[ID]
## Stat changes apply when the game starts up
@export var stats_to_edit: Array[StatChange]
## The triggers needed for this Modifier to apply
@export var triggers: Array[ModifierTrigger]
## The effects that are applied when all triggers have been met.
@export var effects: Array[ModifierEffect]
