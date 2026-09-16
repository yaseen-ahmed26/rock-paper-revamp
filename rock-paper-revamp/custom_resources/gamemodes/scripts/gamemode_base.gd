extends Resource
class_name GamemodeBase

const SHOW_IF = {
	"end_at_stat_threhold": ["stat_thresholds"]
}

enum ID {
	FIRST_TO,
	BEST_OF,
	SURVIVAL,
	COMEBACK,
	ENDLESS
}

@export_category("Metadata")
## The unqiue ID for this gamemode
@export var id: ID
## The name that is displayed on UI
@export var display_name: String
## The description of the gamemode
@export var description: String
## The modifiers to blacklist. This applies before the modifier blacklist
@export var modifier_blacklist: Array[ModifierBase.ID]

@export_category("Properties")
## The stats to change when the game starts
@export var stats_to_edit: Array[StatChange]
## If True, game ends when all rounds have been played. This requires rounds to not be set to -1.
@export var end_at_total_rounds: bool = false
## If True, set a certain stat to meet a threshold to end the game
@export var end_at_stat_threhold: bool = false
## Uses a match statement with the ID for custom logic. 
@export var custom_end_condition: bool = false
## If True, ignores the end condition completely.
@export var ignore_end_condition: bool = false

@export_category("Additional")
## End the game when the stat reaches a certain value. If multiple are set, then all must be exceed to end
@export var stat_thresholds: Dictionary[String, Variant]
