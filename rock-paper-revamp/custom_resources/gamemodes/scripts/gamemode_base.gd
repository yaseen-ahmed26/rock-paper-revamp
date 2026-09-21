extends Resource
class_name GamemodeBase

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
## The stats to change when the game starts
@export var stats_to_edit: Array[StatChange]
## The task list for this specific gamemode
@export var task_pool: Array[TaskBase]

func apply_stats_edit(_game_stats: GameStats):
	pass

func is_game_over(_game_stats: GameStats):
	pass
