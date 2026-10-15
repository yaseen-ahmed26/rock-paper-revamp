extends Node

# Peck
var BASE_URL: String = "https://server.snowstrix.com/"
var SAVES_URL: String = "https://server.snowstrix.com/api/saves/rpr/me"
var REFRESH_URL: String = "https://server.snowstrix.com/api/auth/refresh"

var WEBSOCKET_URL: String = "wss://server.snowstrix.com/api/codes/ws"


func _ready() -> void:
	if OS.has_feature("editor"):
		BASE_URL = "http://127.0.0.1:8000/"
		SAVES_URL = "http://127.0.0.1:8000/api/saves/rpr/me"
		REFRESH_URL = "http://127.0.0.1:8000/api/auth/refresh"
		WEBSOCKET_URL = "ws://127.0.0.1:8000/api/codes/ws"
		print("Using local API base URL: " + BASE_URL)
	else:
		print("Using deployment API base URL: " + BASE_URL)

const TOKENS_PER_GAME = 5
const TOKENS_ON_WIN = 10
const TOKENS_ON_LOSS = 4
const TOKENS_PER_MODIFIER = 2
const TOKENS_PER_TASK = 5

# connect_account.gd
const COUNTRIES: Dictionary[String, String] = {
	"GB": "United Kingdom"
}

# SaveManager
const DEVICE_CFG_FILE_PATH: String = "user://device.cfg"
const SAVE_CFG_FILE_PATH: String = "user://save.cfg"
const DEFAULT_DEVICE_CFG = {
	"username": "",
	"refresh_token": "",
	"save_id": "",
	"peck_connected": false
}
const DEFAULT_DEVICE_SETTINGS_CFG = {
	"window_type": 0,
	"resolution": 2,
	"v_sync": false,
	"max_framerate": 2,
	"icon_waterfall": true
}

# ui_controller.gd
const SCENE_INFO: Dictionary = {
	"rps_selection": {
		"title": "Selection",
		"description": "Pick your [color=green]Gamemode, Modifiers [color=white]and [color=green]Opponent[color=white], then face them!",
	},
	"challenge_selection": {
		"title": "Challenge Selection",
		"description": "[color=green]Challenges [color=white]are preset levels. You cannot choose the Gamemode, Opponent or Modifiers. Once you complete a Challenge, you unlock a [color=green]Modifier[color=white].",
	},
	"rps_results": {
		"title": "Match Results",
		"description": "View how well you did against your opponent. Did badly? [color=green]Retry[color=white], or [color=green]start a new game[color=white].",
	},
	"profile_screen": {
		"title": "Profile",
		"description": "View all your [color=green]lifetime stats[color=white].",
	},
	"connect_account": {
		"title": "Connect Peck Account",
		"description": "Connect your [color=green]Peck [color=white]account to save your data and [color=green]play from other devices[color=white].",
	},
	"credits_screen": {
		"title": "Credits",
		"description": "[color=green]Aseet [color=white]and [color=green]Creator [color=white]credits.",
	},
	"settings_screen": {
		"title": "Settings",
		"description": "Change your [color=green]preferences [color=white]here.",
	}
}
