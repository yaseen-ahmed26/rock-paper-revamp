extends Node

var modifiers: Dictionary[StringName, ModifierBase] = {}
var gamemodes: Dictionary[StringName, GamemodeBase] = {}
var computers: Dictionary[StringName, ComputerBase] = {}
var challenges: Dictionary[StringName, ChallengeBase] = {}

func _ready() -> void:	
	_load_resources("res://custom_resources/modifiers/resources/", modifiers)	
	_load_resources("res://custom_resources/gamemodes/resources/", gamemodes)	
	_load_resources("res://custom_resources/computer_types/resources/", computers)	
	_load_resources("res://custom_resources/challenges/resources/", challenges)

func _load_resources(path: String, target_dict: Dictionary) -> void:	
	var directory = DirAccess.open(path)	
	
	if not directory:		
		push_error("Failed to open directory %s" % path)		
		return
		
	directory.list_dir_begin()	
	var file_name = directory.get_next()
			
	while not file_name.is_empty():	
		if directory.current_is_dir(): return
			
		var clean_name = file_name.trim_suffix(".remap")
	
		if clean_name.ends_with(".tres"):
			var resource = load(path.path_join(clean_name))
			
			if resource:
				var id: String = str(resource.id)
				
				if not id.is_empty():
					target_dict[StringName(id)] = resource
				else:
					push_warning("Resource '%s' has an empty ID and was not loaded." % clean_name)				
		
		file_name = directory.get_next()

func get_modifier_resource(id: String) -> ModifierBase:	
	if not modifiers.has(id):
		print("No modifier found with ID of '%s'" % id)
		return
		
	return modifiers.get(id)
	
func get_gamemode_resource(id: String) -> GamemodeBase:	
	if not gamemodes.has(id):
		print("No gamemode found with ID of '%s'" % id)
		return
	
	return gamemodes.get(id)
	
func get_computer_resource(id: String) -> ComputerBase:	
	if not computers.has(id):
		print("No computer found with ID of '%s'" % id)
		return
	
	return computers.get(id)
	
func get_challenge_resource(id: String) -> ChallengeBase:	
	if not challenges.has(id):
		print("No challenge found with ID of '%s'" % id)
		return
	
	return challenges.get(id)
