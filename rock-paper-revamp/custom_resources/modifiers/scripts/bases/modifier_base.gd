extends Resource
class_name ModifierBase

const SHOW_IF = {
	"modifier_locked": "challenge_required_id",
	"requires_purchase": "purchase_cost"
}

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
	RANDOM_RESET,
	FIFTY_FIFTY,
	DOUBLE_DOWN,
	PITY_POINTS,
	HELPING_HAND,
	REPEAT_REWARD,
	DUEL_DECAY,
	WINNERS_WEAKNESS,
	GRIDLOCKED_GROWTH,
	HEINOUS_HEIST,
	HOT_HAND,
	MOMENTARY_MATCH,
	LAST_LAUGH,
	SCISSOR_SPECIALIST,
	JACKPOT_JUICE,
	INVERTED_INFLATION
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

@export_category("Display")
## The name shown on UI
@export var display_name: String
## The description of this Modifier
@export var description: String
## The group this Modifier belongs to, affects the order in which it is applied.
@export var group: Group
## The icon to display on UI.
@export var icon: Texture

@export_category("Modifier")
## When the Modifier should be applied.
@export var timing: ApplyAt
## Dictates how many triggers need to be met to apply the Modifier
@export var trigger_type: TriggerType
## The modifiers to blacklist when this one is selected.
@export var modifier_blacklist: Array[ID]
## Stat changes apply when the game starts up
@export var stats_to_edit: Array[StatChange]
## The triggers needed for this Modifier to apply
@export var triggers: Array[GameplayTrigger]
## The effects that are applied when all triggers have been met.
@export var effects: Array[ModifierEffect]
## The task list for this specific Modifier
@export var task_pool: Array[TaskBase]

@export_category("Flags")
## If true, only applies the Modifier once, then it is removed from the list.
@export var one_shot: bool = false
## If true, when this Modifier is applied, it does not flash a badge on the UI.
@export var exclude_badge: bool = false
## If true, then a certain challenge must be completed to unlock this Modifier.
@export var modifier_locked: bool = false
## If true, requires a purchase to unlock
@export var requires_purchase: bool = false

@export_category("Additional")
## The ID of the challenge required in order to unlock this Modifier
@export var challenge_required_id: ChallengeBase.ID
## The cost of the modifier.
@export var purchase_cost: int
