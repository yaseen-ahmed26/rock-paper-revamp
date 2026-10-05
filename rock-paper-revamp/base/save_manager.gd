extends Node

"""
1. Needs to load local data
2. Needs to load online data
	- Fallback to local if there is none
3. Needs to save game
	- Handle additive 
4. Needs to setup .cfg files
	- Also sections
"""

const DEVICE_CFG_FILE_PATH: String = "user://device.cfg"
const SAVE_CFG_FILE_PATH: String = "user://save.cfg"
const DEFAULT_DEVICE_CFG = {
	"username": "",
	"refresh_token": "",
	"peck_connected": false
}

var default_save: Dictionary = {}

var device_config: ConfigFile = ConfigFile.new()
var save_config: ConfigFile = ConfigFile.new()

var save_data: Dictionary = {}

# Godot Specific
func _ready() -> void:
	var file = FileAccess.open("res://default_save.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error == OK:
		default_save = json.data
	
	_load_game()
	
# Helper
func _check_cfg_exists(file_path):
	if FileAccess.file_exists(file_path):
		return true
		
	return false

func _load_cfg_files():
	var device_error = device_config.load(DEVICE_CFG_FILE_PATH)

	if device_error != OK:
		print("An error occurred whilst laoding 'device.cfg': ", device_error)

	var save_error = save_config.load(SAVE_CFG_FILE_PATH)

	if save_error != OK:
		print("An error occurred whilst laoding 'save.cfg': ", save_error)
		
# Local
func _setup_save_cfg():
	for k in default_save.keys():
		var v = default_save[k]
	
		save_config.set_value("Save", k, v)
	
	save_config.save(SAVE_CFG_FILE_PATH)
	
func _setup_device_cfg():
	for k in DEFAULT_DEVICE_CFG.keys():
		var v = DEFAULT_DEVICE_CFG[k]
		
		device_config.set_value("Device", k, v)
	
	device_config.save(DEVICE_CFG_FILE_PATH)

func is_peck_connected():
	return device_config.get_value("Device", "peck_connected", false)

func _load_local():
	var saved_stats = {}
	
	for stat in default_save:
		if stat in save_config.get_section_keys("Save"):		
			var saved_v = save_config.get_value("Save", stat)
			saved_stats[stat] = saved_v
		else:
			var default_v = default_save.get(stat)
			save_config.set_value("Save", stat, default_v)
			
			save_config.save(SAVE_CFG_FILE_PATH)
			
			saved_stats[stat] = default_v

	return [true, saved_stats]
	
func _merge_delta(delta):
	print("Save Data:")
	print(save_data)
	print("--------------------------")
	print("Delta:")
	print(delta)
	print("--------------------------")
	
	for k in save_data:
		var saved_v = save_data[k]
		var delta_v = delta[k]
	
		match typeof(saved_v):
			TYPE_STRING, TYPE_BOOL:
				save_data[k] = delta_v
			TYPE_FLOAT, TYPE_INT:
				save_data[k] += delta_v
			TYPE_ARRAY:
				for i in delta_v:
					save_data[k].append(i)
			TYPE_DICTIONARY:
				for new_item in delta_v.keys():
					saved_v[new_item] += delta_v[new_item]
	
func _save_local():
	for k in save_data.keys():
		var v = save_data[k]
		save_config.set_value("Save", k, v)
		
	save_config.save(SAVE_CFG_FILE_PATH)

func record_match(stats: GameStats, gamemode: GamemodeBase, opponent: ComputerBase, modifiers: Array[ModifierBase]):
	var delta: Dictionary = {
		"points_won": int(stats.player_points),
		"points_lost": int(stats.computer_points),
		"rounds_played": stats.rounds_played,
		"matches_played": 1,
		"total_wins": stats.wins,
		"total_losses": stats.losses,
		"total_draws": stats.draws,
		"played_rock": stats.played_moves.get("rock", 0),
		"played_paper": stats.played_moves.get("paper", 0),
		"played_scissors": stats.played_moves.get("scissors", 0),
		"gamemodes": {},
		"opponents": {},
		"modifiers": {},
		"completed_tasks": [],
		"completed_challenges": []
	}

	if gamemode:
		var gm_key: String = GamemodeBase.ID.keys()[gamemode.id].to_lower()
		delta["gamemodes"][gm_key] = 1

	if opponent:
		var opp_key: String = opponent.display_name.to_lower().replace(" ", "_")
		delta["opponents"][opp_key] = 1

	for mod in modifiers:
		var mod_key: String = ModifierBase.ID.keys()[mod.id].to_lower()
		delta["modifiers"][mod_key] = 1
		
	_merge_delta(delta)
	_save_local()
	
# Online
func _load_online():
	pass

func _save_online():
	pass

func account_connected():
	pass

# Logic
func _load_game():
	_load_cfg_files()
	
	if not _check_cfg_exists(DEVICE_CFG_FILE_PATH):
		_setup_device_cfg()
		
	if not _check_cfg_exists(SAVE_CFG_FILE_PATH):
		_setup_save_cfg()
	
	if is_peck_connected():
		# Make HTTP request
		# Then we'd overwrite the local save
		# THEN load
		pass
	
	var details = _load_local()
	
	if details[0]: save_data = details[1]


#
#func save_game() -> void:
	#for key in save_data.keys():
		#save_config.set_value(SECTION_NAME, key, save_data[key])
	#
	#var error = save_config.save(SAVE_CFG_FILE_PATH)
	#
	#if error != OK:
		#push_error("Failed to save config: %d" % error)
#
#func add_stats(delta: Dictionary) -> void:
	#_merge_additive(save_data, delta)
	#save_game()
#
#func _merge_additive(target: Dictionary, source: Dictionary):
	#for key in source.keys():
		#if not target.has(key):
			#target[key] = source[key]
		#elif typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
			#_merge_additive(target[key], source[key])
		#elif typeof(target[key]) in [TYPE_INT, TYPE_FLOAT] and typeof(source[key]) in [TYPE_INT, TYPE_FLOAT]:
			#target[key] += source[key]
		#else:
			#target[key] = source[key]
#
#func _fill_missing_keys(target: Dictionary, template: Dictionary) -> void:
	#for key in template.keys():
		#if not target.has(key):
			#target[key] = template[key]
		#elif typeof(target[key]) == TYPE_DICTIONARY and typeof(template[key]) == TYPE_DICTIONARY:
			#_fill_missing_keys(target[key], template[key])
#
## Game Integration Helper
#func record_match(stats: GameStats, gamemode: GamemodeBase, opponent: ComputerBase, modifiers: Array[ModifierBase]):
	#var delta: Dictionary = {
		#"points_won": int(stats.player_points),
		#"points_lost": int(stats.computer_points),
		#"rounds_played": stats.rounds_played,
		#"matches_played": 1,
		#"total_wins": stats.wins,
		#"total_losses": stats.losses,
		#"total_draws": stats.draws,
		#"played_rock": stats.played_moves.get("rock", 0),
		#"played_paper": stats.played_moves.get("paper", 0),
		#"played_scissors": stats.played_moves.get("scissors", 0),
		#"gamemodes": {},
		#"opponents": {},
		#"modifiers": {}
	#}
#
	#if gamemode:
		#var gm_key: String = GamemodeBase.ID.keys()[gamemode.id].to_lower()
		#delta["gamemodes"][gm_key] = 1
#
	#if opponent:
		#var opp_key: String = opponent.display_name.to_lower().replace(" ", "_")
		#delta["opponents"][opp_key] = 1
#
	#for mod in modifiers:
		#var mod_key: String = ModifierBase.ID.keys()[mod.id].to_lower()
		#delta["modifiers"][mod_key] = 1
#
	#add_stats(delta)
