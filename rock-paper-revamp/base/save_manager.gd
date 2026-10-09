extends Node

var default_save: Dictionary = {}

var device_config: ConfigFile = ConfigFile.new()
var save_config: ConfigFile = ConfigFile.new()

var save_data: Dictionary = {}
var access_token: String

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
	
func _setup_device_cfg():
	for k in Constants.DEFAULT_DEVICE_CFG.keys():
		var v = Constants.DEFAULT_DEVICE_CFG[k]
		
		device_config.set_value("Device", k, v)
	
	device_config.save(Constants.DEVICE_CFG_FILE_PATH)

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
			
			saved_stats[stat] = default_v

	save_config.save(Constants.SAVE_CFG_FILE_PATH)

	return [true, saved_stats]
	
func _merge_delta(delta):
	for k in save_data:
		if k == "bought_modifiers": continue
				
		var saved_v = save_data[k]
		var delta_v = delta[k]
	
		match typeof(saved_v):
			TYPE_STRING, TYPE_BOOL:
				save_data[k] = delta_v
			TYPE_FLOAT, TYPE_INT:
				save_data[k] += delta_v
			TYPE_ARRAY:
				for i in delta_v:
					if i in save_data[k]: continue
					save_data[k].append(i)
			TYPE_DICTIONARY:
				for new_item in delta_v.keys():
					saved_v[new_item] += delta_v[new_item]
	
func save_local():
	for k in save_data.keys():
		var v = save_data[k]
		save_config.set_value("Save", k, v)
		
	save_config.save(Constants.SAVE_CFG_FILE_PATH)
	
	if is_peck_connected(): _save_online()

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
		var gm_key: String = GamemodeBase.ID.keys()[gamemode.id].to_lower()
		delta["gamemodes"][gm_key] = 1

	if opponent:
		var opp_key: String = ComputerBase.ID.keys()[opponent.id].to_lower()
		delta["opponents"][opp_key] = 1

	for mod in modifiers:
		var mod_key: String = ModifierBase.ID.keys()[mod.id].to_lower()
		delta["modifiers"][mod_key] = 1
		
	if challenge:
		var lower = ChallengeBase.ID.keys()[challenge.id].to_lower()
		delta["completed_challenges"].append(lower)
	
	_merge_delta(delta)
	save_local()
	
# Online
func _load_online():
	var details = await RequestManager.send_request(
			true,
			HTTPClient.METHOD_GET,
			["Authorization: Bearer %s" % access_token]
		)
		
	if not details[0]:
		print("An error occurred getting save data")
	else:
		for k in details[1].keys():
			var v = details[1][k]
			save_config.set_value("Save", k, v)
			
	save_config.save(Constants.SAVE_CFG_FILE_PATH)

func _save_online():
	var data = {
		"version_number": 1.0,
		"save_data": save_data
	}
	
	var _details = await RequestManager.send_request(
		true,
		HTTPClient.METHOD_PUT,
		["Content-Type: application/json", "Authorization: Bearer %s" % access_token],
		JSON.stringify(data),
	)

func connect_account(user_data: Dictionary):
	device_config.set_value("Device", "peck_connected", true)
	device_config.set_value("Device", "username", user_data.username)
	device_config.set_value("Device", "refresh_token", user_data.refresh_token)

	device_config.save(Constants.DEVICE_CFG_FILE_PATH)
	
	if user_data.save.is_empty():
		save_local()
		_save_online()
	else:
		save_data = user_data.save
		save_local()
	
	access_token = user_data.access_token

# Logic
func _load_game():
	if not _check_cfg_exists(Constants.DEVICE_CFG_FILE_PATH):
		_setup_device_cfg()
		
	if not _check_cfg_exists(Constants.SAVE_CFG_FILE_PATH):
		_setup_save_cfg()
		
	_load_cfg_files()
	
	if is_peck_connected():
		await _load_online()
	
	var details = _load_local()
	
	if details[0]: save_data = details[1]

func update_tokens(new_tokens: Dictionary):
	access_token = new_tokens.access_token
	
	device_config.set_value("Device", "refresh_token", new_tokens.refresh_token)
	device_config.save(Constants.DEVICE_CFG_FILE_PATH)

func get_refresh_token():
	var refresh_token = device_config.get_value("Device", "refresh_token")
	return refresh_token
