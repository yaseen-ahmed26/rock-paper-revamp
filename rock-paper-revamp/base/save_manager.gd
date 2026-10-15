extends Node

var default_save: Dictionary = {}

var device_config: ConfigFile = ConfigFile.new()
var save_config: ConfigFile = ConfigFile.new()

var local_saved_data: Dictionary = {}
var local_saved_settings: Dictionary = {}

# Godot Specific
func _ready() -> void:
	var file = FileAccess.open("res://default_save.json", FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error == OK:
		default_save = json.data
	
	_load_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		safe_exit()

# Helper
func _check_cfg_exists(file_path):
	if FileAccess.file_exists(file_path):
		return true
		
	return false

func _load_cfg_files():
	var device_error = device_config.load(Constants.DEVICE_CFG_FILE_PATH)

	if device_error != OK:
		print("An error occurred whilst laoding 'device.cfg': ", device_error)

	var save_error = save_config.load(Constants.SAVE_CFG_FILE_PATH)

	if save_error != OK:
		print("An error occurred whilst laoding 'save.cfg': ", save_error)
		
# Local
func _setup_save_cfg():
	for k in default_save.keys():
		var v = default_save[k]
	
		save_config.set_value("Save", k, v)
	
	save_config.save(Constants.SAVE_CFG_FILE_PATH)
	
func _load_local():
	var saved_stats = {}
	
	for stat in default_save:
		if stat in save_config.get_section_keys("Save"):		
			var saved_v = save_config.get_value("Save", stat)
			saved_stats[stat] = saved_v
		else:
			var default_v = default_save.get(stat)
			save_config.set_value("Save", stat, default_v)
			
			saved_stats[stat] = default_v

	save_config.save(Constants.SAVE_CFG_FILE_PATH)

	return [true, saved_stats]
	
func _merge_delta(delta):
	for k in local_saved_data:
		if k == "bought_modifiers": continue
				
		var saved_v = local_saved_data[k]
		var delta_v = delta[k]
	
		match typeof(saved_v):
			TYPE_STRING, TYPE_BOOL:
				local_saved_data[k] = delta_v
			TYPE_FLOAT, TYPE_INT:
				local_saved_data[k] += delta_v
			TYPE_ARRAY:
				for i in delta_v:
					if i in local_saved_data[k]: continue
					local_saved_data[k].append(i)
			TYPE_DICTIONARY:
				for new_item in delta_v.keys():
					saved_v[new_item] += delta_v[new_item]
	
func save_local(data = local_saved_data):
	print("Saving data locally.")
	
	for k in data.keys():
		var v = data[k]
		save_config.set_value("Save", k, v)
		
	save_config.save(Constants.SAVE_CFG_FILE_PATH)
	
	if PeckManager.is_account_connected(): PeckManager.save_data(data)

func record_match(
	stats: GameStats,
	gamemode: GamemodeBase, 
	opponent: ComputerBase, 
	modifiers: Array[ModifierBase],
	tasks_completed: int,
	challenge: ChallengeBase = null
):
	var delta: Dictionary = {
		"tokens": PlayerManager.calculate_tokens(stats, modifiers, tasks_completed),
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
		delta["gamemodes"][gamemode.id] = 1

	if opponent:
		delta["opponents"][opponent.id] = 1

	for modifier in modifiers:
		delta["modifiers"][modifier.id] = 1
		
	if challenge:
		delta["completed_challenges"].append(challenge.id)
	
	_merge_delta(delta)
	save_local()

# Logic
func _load_game():		
	if not _check_cfg_exists(Constants.SAVE_CFG_FILE_PATH):
		_setup_save_cfg()
		
	_load_cfg_files()
	_load_settings()
	
	var details = _load_local()
	
	if details[0]: local_saved_data = details[1]

# Settings
func _load_settings():
	var section_keys = device_config.get_section_keys("Settings")
	
	for k in section_keys:
		var v  = device_config.get_value("Settings", k)
		
		local_saved_settings[k] = v

func save_settings(settings: Dictionary):
	print("Saving settings locally.")
	
	for k in settings.keys():
		var v = settings[k]
		device_config.set_value("Settings", k, v)
	
	device_config.save(Constants.DEVICE_CFG_FILE_PATH)

	local_saved_settings = settings

# Contingency
func safe_exit():
	print("Safe exit has ran.")
	set_process(false)
	await save_local()
	get_tree().quit()
