extends Node

const SAVE_CFG_FILE_PATH: String = "user://save.cfg"
const TEMPLATE_PATH: String = "res://default_save.json" # Adjust if inside res://base/
const SECTION_NAME: String = "Save"

var save_config: ConfigFile = ConfigFile.new()
var default_save: Dictionary = {}
var save_data: Dictionary = {}

# Godot Specific
func _ready() -> void:
	default_save = _load_json(TEMPLATE_PATH)
	_load_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		safe_exit()

# Helpers
func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Template file not found at %s" % path)
		
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error == OK:
		return json.data
	
	push_error("JSON Parse Error in %s: %s" % [path, json.get_error_message()])
	
	return {}

# Logic
func _load_game():
	if not FileAccess.file_exists(SAVE_CFG_FILE_PATH):
		save_data = default_save.duplicate(true)
		save_game()
		
		return

	var error = save_config.load(SAVE_CFG_FILE_PATH)
	
	if error != OK:
		push_error("Failed to load '%s': %d" % [SAVE_CFG_FILE_PATH, error])
		save_data = default_save.duplicate(true)
		
		return

	save_data = {}
	
	if save_config.has_section(SECTION_NAME):
		for key in save_config.get_section_keys(SECTION_NAME):
			save_data[key] = save_config.get_value(SECTION_NAME, key)

	_fill_missing_keys(save_data, default_save)

func save_game() -> void:
	for key in save_data.keys():
		save_config.set_value(SECTION_NAME, key, save_data[key])
	
	var error = save_config.save(SAVE_CFG_FILE_PATH)
	
	if error != OK:
		push_error("Failed to save config: %d" % error)

func add_stats(delta: Dictionary) -> void:
	_merge_additive(save_data, delta)
	save_game()

func _merge_additive(target: Dictionary, source: Dictionary):
	for key in source.keys():
		if not target.has(key):
			target[key] = source[key]
		elif typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
			_merge_additive(target[key], source[key])
		elif typeof(target[key]) in [TYPE_INT, TYPE_FLOAT] and typeof(source[key]) in [TYPE_INT, TYPE_FLOAT]:
			target[key] += source[key]
		else:
			target[key] = source[key]

func _fill_missing_keys(target: Dictionary, template: Dictionary) -> void:
	for key in template.keys():
		if not target.has(key):
			target[key] = template[key]
		elif typeof(target[key]) == TYPE_DICTIONARY and typeof(template[key]) == TYPE_DICTIONARY:
			_fill_missing_keys(target[key], template[key])

# Game Integration Helper
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
		"modifiers": {}
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

	add_stats(delta)

# Contingency
func safe_exit() -> void:
	set_process(false)
	save_game()
	get_tree().quit()
