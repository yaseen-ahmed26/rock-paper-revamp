extends Resource
class_name ModifierBase

const SHOW_IF: Dictionary = {
	"apply_on_start": ["stats_to_edit_start"],
	"has_chance": ["chance_to_apply"],
	"apply_every_x": ["apply_every"],
	"edit_stats_on_apply": ["stats_to_edit_apply"]
}

enum ID {}
enum Group {
	UI,
	POINTS,
	OUTCOME,
	MISC
}

@export_category("Metadata")
## The unique ID for this Modifier
@export var id: ID
## The name shown on UI
@export var display_name: String
## The description of this Modifier, shown on the menus
@export var description: String
## The text shown when this modifier applies or happens.
@export var message: String
## The group this Modifier belongs to, affects the order in which it is applied.
@export var group: Group
## The modifiers to blacklist when this one is selected.
@export var modifier_blacklist: Array[ID]

@export_category("Flags")
## If True, remove the modifier from the pool once it has been applied.
@export var one_shot: bool = false
## Edit the initial stats before the game starts. Works the same as gamemodes but are applied after.
@export var apply_on_start: bool = false
## If True, set a chance for the Modifier to apply.
@export var has_chance: bool = false
## If True, sets the modifier to only apply every X rounds.
@export var apply_every_x: bool = false
## If True, set which stats should be edited 
@export var edit_stats_on_apply: bool = false
## If True, ignores all other flags and uses the ID to apply custom logic
@export var custom: bool = false

@export_category("Properties")
## The stats to edit when the game starts.
@export var stats_to_edit_start: Array[StatChange]
## The chance at which this Modifier applies.
@export_range(0.01, 1.0) var chance_to_apply
## Applies this Modifier every X round. (e.g. applies every 3 rounds)
@export var apply_every: int
## The stats to edit when the Modifier is applied.
@export var stats_to_edit_apply: Array[StatChange]
