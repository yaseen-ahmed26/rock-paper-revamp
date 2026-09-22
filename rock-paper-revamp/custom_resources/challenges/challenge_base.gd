extends Resource
class_name ChallengeBase

enum ID {
	INVERTED_DEATH
}

enum Difficulty {
	EASY,
	MODERATE,
	HARD
}

@export_group("Metadata")
@export var id: ID
@export var display_name: String
@export var description: String
@export var difficulty: Difficulty

@export_group("Rules")
@export var locked_gamemode: GamemodeBase
@export var locked_modifiers: Array[ModifierBase]

func get_lower_difficulty():
	return Difficulty.keys()[difficulty].to_lower()

func get_modifier_names():
	var modifier_names: Array = []
	
	for modifier in locked_modifiers:
		modifier_names.append(modifier.display_name)
	
	return modifier_names	
