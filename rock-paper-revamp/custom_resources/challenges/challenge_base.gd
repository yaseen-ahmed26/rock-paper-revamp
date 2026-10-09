extends DescribedBase
class_name ChallengeBase

enum Difficulty {
	EASY,
	MODERATE,
	HARD
}

@export_group("Challenge Described")
## The difficulty to show on UI. This is purely cosmetic.
@export var difficulty: Difficulty
## The name of the reward that this challenge unlocks. This is shown purely for UI, actual reward unlocking is handled elsewhere.
@export var reward: String

@export_group("General")
@export var locked_gamemode: GamemodeBase
@export var locked_modifiers: Array[ModifierBase]
@export var locked_computer: ComputerBase

func get_lower_difficulty():
	return Difficulty.keys()[difficulty].to_lower()

func get_modifier_names():
	var modifier_names: Array = []
	
	for modifier in locked_modifiers:
		modifier_names.append(modifier.display_name)
	
	return modifier_names	

func get_gamemode_name():
	return locked_gamemode.display_name

func get_opponent_name():
	return locked_computer.display_name
