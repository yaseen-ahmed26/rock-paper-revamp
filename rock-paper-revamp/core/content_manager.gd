extends Node

var modifiers: Dictionary[StringName, ModifierBase] = {}
var gamemodes: Dictionary[StringName, GamemodeBase] = {}
var computers: Dictionary[StringName, ComputerBase] = {}
var challenges: Dictionary[StringName, ChallengeBase] = {}
var contracts: Dictionary[StringName, ContractBase]
var achievements: Dictionary[StringName, AchievementBase] = {}

var cards: Dictionary[StringName, CardBase] = {}

func _ready() -> void:	
	_load_resources("res://content/modifiers/", modifiers)	
	_load_resources("res://content/gamemodes/", gamemodes)	
	_load_resources("res://content/computers/", computers)	
	_load_resources("res://content/challenges/", challenges)
	_load_resources("res://content/cards/", cards)
	_load_resources("res://content/contracts/", contracts)
	_load_resources("res://content/achievements/", achievements)

	_generate_stat_achievements()

func _load_resources(path: String, target_dict: Dictionary) -> void:	
	var directory = DirAccess.open(path)	
	
	if not directory:		
		push_error("Failed to open directory %s" % path)		
		return
		
	directory.list_dir_begin()	
	var file_name = directory.get_next()
			
	while not file_name.is_empty():	
		if directory.current_is_dir():
			file_name = directory.get_next()
			continue
			
		var clean_name = file_name.trim_suffix(".remap")
	
		if clean_name.ends_with(".tres"):
			var resource = load(path.path_join(clean_name))
			
			if resource:
				if resource.exclude_from_loading:
					file_name = directory.get_next()
					continue
				
				var id: String = str(resource.id)
				
				if not id.is_empty():
					target_dict[StringName(id)] = resource
				else:
					push_warning("Resource '%s' has an empty ID and was not loaded." % clean_name)				
		
		file_name = directory.get_next()

func _generate_stat_achievements() -> void:
	for suit in [&"rock", &"paper", &"scissors", &"lizard", &"spock"]:
		_register_achievement(
			&"play_%s" % suit,
			"Play %s" % str(suit).capitalize(),
			&"played_%s" % suit,
			&"",
			[10, 50, 100],
			"Play matches using %s cards %d times."
		)

	# 2. Gamemode achievements
	for gamemode_id in gamemodes.keys():
		var gamemode = gamemodes[gamemode_id]
		
		_register_achievement(
			&"mode_%s" % gamemode_id,
			"Play %s" % gamemode.display_name,
			&"gamemodes",
			gamemode_id,
			[5, 15, 30],
			"Play matches in the %s gamemode %d times." % [gamemode.display_name, 0]
		)

	for computer_id in computers.keys():
		var computer = computers[computer_id]
		_register_achievement(
			&"comp_%s" % computer_id,
			"Defeat %s" % computer.display_name,
			&"opponents",
			computer_id,
			[5, 15, 30],
			"Play matches against %s %d times." % [computer.display_name, 0]
		)

	for modifier_id in modifiers.keys():
		var modifier = modifiers[modifier_id]
		_register_achievement(
			&"mod_%s" % modifier_id,
			"Master %s" % modifier.display_name,
			&"modifiers",
			modifier_id,
			[5, 15, 30],
			"Play matches with %s active %d times." % [modifier.display_name, 0]
		)

func _register_achievement(
	id: StringName, 
	title: String, 
	key: StringName, 
	target: StringName, 
	steps: Array[int],
	description: String
):
	var new := AchievementBase.new()
	new.id = id
	new.display_name = title
	new.stat_key = key
	new.target_id = target
	new.thresholds = steps
	new.description = description
	achievements[id] = new

func get_modifier_resource(id: StringName) -> ModifierBase:	
	if not modifiers.has(id):
		print("No Modifier found with ID of '%s'" % str(id))
		return
		
	return modifiers.get(id)
	
func get_gamemode_resource(id: StringName) -> GamemodeBase:	
	if not gamemodes.has(id):
		print("No Gamemode found with ID of '%s'" % str(id))
		return
	
	return gamemodes.get(id)
	
func get_computer_resource(id: StringName) -> ComputerBase:	
	if not computers.has(id):
		print("No Computer found with ID of '%s'" % str(id))
		return
	
	return computers.get(id)
	
func get_challenge_resource(id: StringName) -> ChallengeBase:	
	if not challenges.has(id):
		print("No Challenge found with ID of '%s'" % str(id))
		return
	
	return challenges.get(id)

func get_contract_resource(id: StringName) -> ContractBase:
	if not contracts.has(id):
		print("No Contract found with ID of '%s'" % str(id))
		return
	
	return contracts.get(id)

func get_achivement_resource(id: StringName) -> ContractBase:
	if not achievements.has(id):
		print("No Achivement found with ID of '%s'" % str(id))
		return
	
	return achievements.get(id)
