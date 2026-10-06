extends Control

@onready var menu_buttons: VBoxContainer = $MenuButtons

var redirect_modal: ModalBase = preload("res://custom_resources/modals/redirect_to_website.tres")
var confirm_sign_modal: ModalBase = preload("res://custom_resources/modals/confirm_sign_in.tres")

func _ready() -> void:
	for btn: Button in menu_buttons.get_children():
		btn.pressed.connect(_on_menu_btn_pressed.bind(btn))
		
func _on_menu_btn_pressed(btn: Button):
	match btn.name:
		"Play":
			Signals.change_screen.emit("rps_selection")
		"Challenges":
			Signals.change_screen.emit("challenge_selection")
		"Profile":
			Signals.change_screen.emit("profile_screen")
		"Credits":
			Signals.change_screen.emit("credits_screen")
		"Quit":
			get_tree().quit()

func _on_peck_button_pressed():
	if SaveManager.is_peck_connected():
		Signals.show_modal.emit(redirect_modal)
	else:
		Signals.show_modal.emit(confirm_sign_modal)
		
		var response: bool = await Signals.modal_response
		
		if response:
			Signals.change_screen.emit("connect_account")
