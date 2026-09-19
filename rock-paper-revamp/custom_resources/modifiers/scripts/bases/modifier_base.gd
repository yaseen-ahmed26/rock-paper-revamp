extends Resource
class_name ModifierBase

enum ID {
	COPY_CAT,
	CHOICE_COOLDOWN,
	THOUGHT_TAX,
	VAMPIRE_VICTORY,
	ROLLING_RUN,
	SAFETY_SHIELD,
	TAX_TOLL,
	POINT_PERK,
	ARTIFICAL_ADVANTAGE,
	RULE_REVERSAL,
	RANDOM_RESET
}
enum Group {
	UI,
	POINTS,
	OUTCOME,
	MISC
}
enum ApplyAt {
	ROUND_START,
	ROUND_END,
	EVERY_SECOND
}
enum TriggerType {
	ALL_REQUIRED,
	ANY
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
## Dictates how many triggers need to be met to apply the Modifier
@export var trigger_type: TriggerType
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
