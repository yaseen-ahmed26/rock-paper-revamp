extends Node

var device_config: ConfigFile = ConfigFile.new()

var peck_server_down: bool = false
var no_internet: bool = false

var online_saved_data: Dictionary = {}

var access_token: String

var prevent_api_check: bool = true
 
func _ready() -> void:
	_load_device_cfg()
	await check_connections()
	
func _load_device_cfg():
	if not FileAccess.file_exists(Constants.DEVICE_CFG_FILE_PATH):
		_setup_device_cfg()
	
	var device_error = device_config.load(Constants.DEVICE_CFG_FILE_PATH)

	if device_error != OK:
		print("An error occurred whilst laoding 'device.cfg': ", device_error)

func _setup_device_cfg():
	for k in Constants.DEFAULT_DEVICE_CFG.keys():
		var v = Constants.DEFAULT_DEVICE_CFG[k]
		
		device_config.set_value("Device", k, v)
	
	for k in Constants.DEFAULT_DEVICE_SETTINGS_CFG.keys():
		var v = Constants.DEFAULT_DEVICE_SETTINGS_CFG[k]
		
		device_config.set_value("Settings", k, v)
	
	device_config.save(Constants.DEVICE_CFG_FILE_PATH)
	
func _get_refresh_token():
	var refresh_token = device_config.get_value("Device", "refresh_token")
	return refresh_token
	
func _update_tokens(new_tokens):
	access_token = new_tokens.access_token
	
	device_config.set_value("Device", "refresh_token", new_tokens.refresh_token)
	device_config.save(Constants.DEVICE_CFG_FILE_PATH)

func send_http_request(
	method: HTTPClient.Method,
	url: String = Constants.SAVES_URL,
	headers: Array = [], 
	data: String = "", 
	is_refresh: bool = false
) -> Array:	
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)

	var error: Error

	if method == HTTPClient.METHOD_GET:
		error = http_request.request(url, headers)
	else:
		error = http_request.request(url, headers, method, data)

	if error != OK:
		print("An error occurred making the HTTP request")
		http_request.queue_free()
		return [false, null, 0]
	
	var response = await http_request.request_completed
	
	var result = response[0]
	var response_code = response[1]
	var body = response[3]	
	
	http_request.queue_free()
	
	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code == 401:
			if is_refresh:
				print("Refresh failed.")
				return [false, null, response_code]
			
			var refresh_payload = JSON.stringify({"refresh_token": _get_refresh_token()})
			var refresh_headers = ["Content-Type: application/json"]
			var refresh_result = await send_http_request(HTTPClient.METHOD_POST, Constants.REFRESH_URL, refresh_headers, refresh_payload, true)
			
			if not refresh_result[0]:
				return [false, null, response_code]
			
			_update_tokens(refresh_result[1])
		
			var new_headers: Array = []
			
			for h in headers:
				if not h.begins_with("Authorization:"):
					new_headers.append(h)
					
			new_headers.append("Authorization: Bearer " + access_token)
					
			return await send_http_request(method, url, new_headers, data, true)
		
		if body:
			var json = JSON.parse_string(body.get_string_from_utf8())
			return [true, json, response_code]
		else:
			return [true, null, response_code]
	else:
		push_warning("Failed to make %s request, response code: %d" % [method, response_code])
		return [false, null, response_code]

func check_connections():
	if prevent_api_check:
		if OS.has_feature("editor"):
			print("(In Engine) 'prevent_api_check' is true, no initial API checks will be made.")
			return
		else:
			print("'prevent_api_check' cannot be true in exported builds.")
	else:
		print("Starting API health check.")
	
	var details = await send_http_request(
		HTTPClient.METHOD_GET,
		Constants.BASE_URL,
	)

	if not details[0]:
		print("Request to Peck Server has failed. Response Code: %d" % details[2])
		
		if details[2] == 0:
			var check_alternative = await send_http_request(
				HTTPClient.METHOD_GET,
				"http://connectivitycheck.gstatic.com/generate_204"
			)

			if not check_alternative[0]:
				print("The player has no internet connection. Response Code: %d" % check_alternative[2])
				no_internet = true
			else:
				print("Alternative Google/204 check succeeded. Likely the Peck Server is offline. Response Code: %d" % check_alternative[2])
				no_internet = false
				peck_server_down = true
		else:
			print("An error has occurred checking Server health, Response Code: %d" % details[2])
			no_internet = false
	else:
		print("Server health check succeeded, Response Code: %d" % details[2])
		peck_server_down = false
		no_internet = false
	
	if not no_internet and not peck_server_down:
		if is_account_connected():
			print("Peck account connected, attempting to load data.")
			_load_online_save()
	
	print("Peck Server Down: ", peck_server_down)
	print("Player Internet Offline: ", no_internet)

func _load_online_save():
	print("Loading online data (initial).")
	var details = await send_http_request(
		HTTPClient.METHOD_GET,
		Constants.SAVES_URL,
		["Authorization: Bearer %s" % access_token]
	)
		
	if not details[0]:
		print("An error occurred loading save data, Response Code: %d" % details[2])
		online_saved_data = {}
		return
			
	online_saved_data = details[1]

# Public Methods
func get_data():
	return online_saved_data

func save_data(data: Dictionary):
	print("Saving data online.")
	var _details = await send_http_request(
		HTTPClient.METHOD_PUT,
		Constants.SAVES_URL,
		["Content-Type: application/json", "Authorization: Bearer %s" % access_token],
		JSON.stringify({
			"version_number": 1.0,
			"save_data": data
		}),
	)

func new_account_connected(user_data: Dictionary):
	device_config.set_value("Device", "peck_connected", true)
	device_config.set_value("Device", "username", user_data.username)
	device_config.set_value("Device", "refresh_token", user_data.refresh_token)

	device_config.save(Constants.DEVICE_CFG_FILE_PATH)
	
	if user_data.save.is_empty():
		SaveManager.save_local()
	else:
		online_saved_data = user_data.save
		SaveManager.local_saved_data = online_saved_data
		SaveManager.save_local(online_saved_data)
	
	access_token = user_data.access_token

func is_account_connected():
	return device_config.get_value("Device", "peck_connected")
