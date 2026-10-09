class_name ModifierBase
extends DescribedBase

const SHOW_IF = {
	"challenge_required": "challenge_id",
	"requires_purchase": "purchase_cost",
	"has_mastery": ["mastery_requirement", "mastery_version"],
	"has_internal": "internal_state"
}

enum ApplyAt {
	## Applied right after a new round starts, before any moves are picked and the timer starts.
	ROUND_START,
	## Applied right after the timer ends but applied BEFORE an outcome is decided and scores are awarded.
	ROUND_END,
	## Applied every second the timer is running.
	EVERY_SECOND
}
enum Group {
	## Affects the player's move.
	MOVE,
	## Affects the outcome of the round.
	OUTCOME,
	## Affects outcome or point global multiplier.
	MULTIPLIER,
	## Affects the player or AI's score.
	SCORE,
	## Other modifiers, these are applied last.
	MISC,
}

@export_group("Modifier Described")
## The tier in which it belongs to. This is used for UI and does not affect the modifier is anyway.
@export_range(1, 5, 1) var tier: int

@export_group("General")
## When the modifier should be applied.
@export var timing: ApplyAt
## The group in which the modifier belongs to. This affects the order of which the modifiers are applied in.
@export var group: Group
## Stat changes apply when the game starts up. These only apply once.
@export var starting_stat_changes: Array[StatChange]
## The modifiers to blacklist when this one is selected. Note that this uses the ID (found in Shared Described), keep in mind of spelling errors. This does warn if that ID is not found when the game runs.
@export var blacklist: Array[StringName]
## The rules of the modifier. Each rule contains Array[ModifierTrigger] and Array[ModifierEffect]. These rules do not need to be the same, i.e. if/elif/else.
@export var rules: Array[ModifierRule]

@export_group("Flags")
## If true, only applies the modifier once. 
@export var one_shot: bool = false
## If true, when this modiifer is applied, it's icon will not flash on the UI to signify it has applied.
@export var exclude_badge: bool = false
## If true, then a certain challenge must be completed to unlock this modifier.
@export var challenge_required: bool = false
## If true, requires a purchase to unlock. Note that this is ignored if challenge_required is true.
@export var requires_purchase: bool = false
## If true, then this modifier has a mastery that is a stronger version of the base.
@export var has_mastery: bool = false
## If true, then this modifier has it's own internal state. For example, charges. 
@export var has_internal: bool = false

@export_group("Advanced")
## The ID of the challenge required in order to unlock this modifier. Note that this uses the ID (found in Shared Described), keep in mind of spelling errors. This does warn if that ID is not found when the game runs.
@export var challenge_id: StringName
## The cost of the modifier.
@export var purchase_cost: int
## The usage requirement of the base modifier to unlock it's mastery.
@export var mastery_requirement: int
## The stronger base version of this modifier.
# @export var mastery_version: ModifierMastery
## It's own internal state, contains charges.
@export var internal_state: ModifierInternal

var applied: bool = false

func setup():
	applied = false
	
	if internal_state:
		internal_state.initalize()

func check_rules_and_apply(stats: GameStats, apply_timing: ApplyAt):
	if stats.rounds_played == 1: return
	if apply_timing != timing: return
	
	var rules_met: int = 0
	
	for rule in rules:
		var met = rule.check_and_apply(stats, internal_state)
		if met: rules_met += 1
	
	if rules_met >= 1 and one_shot:
		applied = true
