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

@export_category("Properties")
## The stats to change when the game starts
@export var stats_to_edit: Array[StatChange]
## End the game when the stat reaches a certain value
@export var end_when_stat_at: Dictionary[String, Variant]
## Uses a match statement with the ID for custom logic. 
@export var custom_end_condition: bool = false
