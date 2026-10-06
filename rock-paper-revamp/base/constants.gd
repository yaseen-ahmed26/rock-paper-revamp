extends Node
class_name Constants

const TOKENS_PER_GAME = 5
const TOKENS_ON_WIN = 10
const TOKENS_ON_LOSS = 4
const TOKENS_PER_MODIFIER = 2

# connect_account.gd
const WEBSOCKET_URL: String = "ws://127.0.0.1:8000/api/codes/ws"
const COUNTRIES: Dictionary[String, String] = {
	"GB": "United Kingdom"
}

# RequestManager
const SAVES_URL: String = "http://127.0.0.1:8000/api/saves/rpr/me"
const REFRESH_URL: String = "http://127.0.0.1:8000/api/auth/refresh"

# SaveManager
const DEVICE_CFG_FILE_PATH: String = "user://device.cfg"
const SAVE_CFG_FILE_PATH: String = "user://save.cfg"
const DEFAULT_DEVICE_CFG = {
	"username": "",
	"refresh_token": "",
	"save_id": "",
	"peck_connected": false
}
