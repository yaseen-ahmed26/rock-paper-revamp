extends Control

const COUNTRIES: Dictionary[String, String] = {
	"GB": "United Kingdom"
}

var client: HTTPClient = HTTPClient.new()
var socket: WebSocketPeer = WebSocketPeer.new()

var websocket_url: String = "ws://127.0.0.1:8000/api/codes/ws"

var connected = false
var code: String = ""

func _ready() -> void:	
	set_process(false)

func _process(_delta: float) -> void:
	socket.poll()
	
	var state = socket.get_ready_state()
	
	while socket.get_available_packet_count() > 0:
		var packet = socket.get_packet()
		var message = packet.get_string_from_utf8()
		
		_on_message_received(message)
	
	if state == WebSocketPeer.STATE_OPEN:
		if not connected:
			_on_connected()
			connected = true
			
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var close_code = socket.get_close_code()
		var reason = socket.get_close_reason()
		
		print("websocket closed: (%d) %s" % [close_code, reason])
		set_process(false)
		connected = false

func start_websocket():
	var current_state = socket.get_ready_state()
	
	if current_state != WebSocketPeer.STATE_CLOSED:
		socket.close()
		connected = false
	
	await get_tree().create_timer(1.0).timeout
	
	var os_name: String = OS.get_name()
	var country_name: String = _get_user_country()

	var websocket_metadata = {
		"os": os_name,
		"country": country_name,
		"game_id": "biscuit"
	}
	
	var query_string = client.query_string_from_dict(websocket_metadata)
	
	set_process(true)
	
	var error = socket.connect_to_url(websocket_url + "?" + query_string)
	
	if error != OK:
		print("failed to connect to the websocket: ", error)
		set_process(false)

func _get_user_country() -> String:
	var locale_parts: PackedStringArray = OS.get_locale().split("_")
	var country_code: String = "def"
	
	if locale_parts.size() > 1:
		country_code = locale_parts[1].left(2).to_upper() 
	
	var country_name: String = COUNTRIES.get(country_code, country_code)
	
	return country_name

func _account_link_success(username: String, save: Dictionary):
	Signals.show_modal.emit("account_link", [username])
		
	var confirmation = await Signals.modal_response
	
	if confirmation:
		Signals.change_screen.emit("game")
		
		if save.is_empty():
			await get_tree().create_timer(1.0).timeout
			Signals.show_modal.emit("welcome_bonus")
	
func _websocket_expired():
	Signals.show_modal.emit("websocket_expired")
	
	$Code.text = "-------"
	# $copy_code_btn.disabled = true
	
	var confirmation = await Signals.modal_response
	
	if confirmation:
		# $copy_code_btn.disabled = false
		start_websocket()
	else:
		Signals.change_screen.emit("main_menu")
	
func _on_message_received(message):
	var parsed = JSON.parse_string(message)

	if parsed.type == "information":
		$Code.text = "[color=green]%s" % parsed.login_code
		code = parsed.login_code
	elif parsed.type == "user_data":	
		SaveManager.connect_account(parsed)
		_account_link_success(parsed.username, parsed.save)
		
		socket.close()
	elif parsed.type == "expired":
		_websocket_expired()

func _send_message(message: String) -> void:
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var error = socket.send_text(message)
		
		if error != OK:
			print("error sending message: ", error)

func _on_connected() -> void:	
	# var json_string = JSON.stringify(player_data)
	# socket.send_text(json_string)
	pass

func on_screen_change():
	start_websocket()
	
func _on_copy_code_btn_pressed() -> void:
	DisplayServer.clipboard_set(code)

	$copy_code_btn.text = "COPIED"
	await get_tree().create_timer(2.0).timeout
	$copy_code_btn.text = "Copy to clipboard"

func _on_welcome_meta_clicked(_meta: Variant) -> void:
	OS.shell_open("https://peck.projecthatchlings.xyz/")
