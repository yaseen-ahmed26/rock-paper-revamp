extends Resource
class_name GamemodeBase

enum ID {
	FIRST_TO,
	BEST_OF,
	SURVIVAL,
	COMEBACK,
	ENDLESS,
	RACE_TO_LAST
}

@export_group("Metadata")
## The unqiue ID for this gamemode
@export var id: ID
## The name that is displayed on UI
@export var display_name: String
## The description of the gamemode
@export var description: String
## A notice to display on the UI for a custom message.
@export var notice: String

@export_group("Rules")
## The modifiers to blacklist. This applies before the modifier blacklist
# @export var modifier_blacklist: Array[ModifierBase.ID]
## The stats to change when the game starts
@export var stats_to_edit: Array[StatChange]
## The task list for this specific gamemode
@export var task_pool: Array[TaskBase]

func get_customisable_settings():
	return {}

func apply_stats_edit(_game_stats: GameStats):
	pass

func is_game_over(_game_stats: GameStats):
	return false
