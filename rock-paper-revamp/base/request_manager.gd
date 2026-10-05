extends Node

var saves_url: String = "http://127.0.0.1:8000/api/saves/rpr/me"
var refresh_url: String = "http://127.0.0.1:8000/api/auth/refresh"

func _ready() -> void:
	pass

func send_request(use_saves_url: bool, method: HTTPClient.Method, headers: Array = [], data: String = "", is_refresh: bool = false) -> Array:	
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)

	var error: Error
	var url: String = saves_url if use_saves_url else refresh_url

	if method == HTTPClient.METHOD_GET:
		error = http_request.request(url, headers)
	else:
		error = http_request.request(url, headers, method, data)

	if error != OK:
		print("An error occurred making the HTTP request")
		http_request.queue_free()
		return [false]
	
	var response = await http_request.request_completed
	
	var result = response[0]
	var response_code = response[1]
	var body = response[3]	
	
	http_request.queue_free()
	
	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code == 401:
			if is_refresh:
				print("Refresh failed.")
				return [false]
			
			var refresh_payload = JSON.stringify({"refresh_token": SaveManager.get_refresh_token()})
			var refresh_headers = ["Content-Type: application/json"]
			var refresh_result = await send_request(false, HTTPClient.METHOD_POST, refresh_headers, refresh_payload, true)
			
			if not refresh_result[0]:
				return [false]
			
			SaveManager.update_tokens(refresh_result[1])
		
			var new_headers: Array = []
			
			for h in headers:
				if not h.begins_with("Authorization:"):
					new_headers.append(h)
					
			new_headers.append("Authorization: Bearer " + SaveManager.access_token)
					
			return await send_request(true, method, new_headers, data, true)
		
		var json = JSON.parse_string(body.get_string_from_utf8())
		return [true, json]
	else:
		push_warning("Failed to make %s request, response code: %d" % [method, response_code])
		return [false]
