extends DescribedBase
class_name GamemodeBase

@export_group("Gamemode Described")
## A notice to display on the UI for a custom message.
@export var notice: String

@export_group("General")
## The modifiers to blacklist. This applies before the modifier blacklist
@export var modifier_blacklist: Array[StringName]
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
