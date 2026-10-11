extends Control

@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var side_buttons: VBoxContainer = $SideButtons
@onready var icon_waterfall: Control = $IconWaterfall

var redirect_modal: ModalBase = preload("res://custom_resources/modals/redirect_to_website.tres")
var confirm_sign_modal: ModalBase = preload("res://custom_resources/modals/confirm_sign_in.tres")
var why_revamped_modal: ModalBase = preload("res://custom_resources/modals/why_revamped.tres")
var latest_update_modal: ModalBase = preload("res://custom_resources/modals/latest_update.tres")
var refusal_no_internet = preload("res://custom_resources/modals/refusal_no_internet.tres")
var refusal_server_down = preload("res://custom_resources/modals/refusal_server_down.tres")

func _ready() -> void:
	for btn: Button in menu_buttons.get_children():
		btn.pressed.connect(_on_menu_btn_pressed.bind(btn))
		
	for btn: Button in side_buttons.get_children():
		btn.pressed.connect(_on_side_btn_pressed.bind(btn))
		btn.mouse_entered.connect(_on_side_btn_hover_enter.bind(btn))
		btn.mouse_exited.connect(_on_side_btn_hover_exit.bind(btn))
		
func _on_menu_btn_pressed(btn: Button):
	match btn.name:
		"Play":
			Signals.change_screen.emit("rps_selection")
		"Challenges":
			Signals.change_screen.emit("challenge_selection")
		"Profile":
			Signals.change_screen.emit("profile_screen")
		"Settings":
			Signals.change_screen.emit("settings_screen")
		"Credits":
			Signals.change_screen.emit("credits_screen")
		"Quit":
			SaveManager.save_local()
			get_tree().quit()
	
	await get_tree().create_timer(0.5).timeout	
	icon_waterfall.enabled = false

func _on_side_btn_pressed(btn: Button):
	match btn.name:
		"Revamped":
			Signals.show_modal.emit(why_revamped_modal)
		"Updates":
			Signals.show_modal.emit(latest_update_modal)
	
func _on_side_btn_hover_enter(btn: Button):
	var hover_label = btn.get_node_or_null("HoverLabel")
	if hover_label: hover_label.visible = true
	
func _on_side_btn_hover_exit(btn: Button):
	var hover_label = btn.get_node_or_null("HoverLabel")
	if hover_label: hover_label.visible = false

func _on_peck_button_pressed():
	if PeckManager.no_internet:
		Signals.show_modal.emit(refusal_no_internet)
		return
	elif PeckManager.peck_server_down:
		Signals.show_modal.emit(refusal_server_down)
		return
	
	if PeckManager.is_account_connected():
		Signals.show_modal.emit(redirect_modal)
	else:
		Signals.show_modal.emit(confirm_sign_modal)
		
		var response: bool = await Signals.modal_response
		
		if response:
			Signals.change_screen.emit("connect_account")

func on_screen_change(_args):
	if SaveManager.local_saved_settings.get("icon_waterfall"):
		icon_waterfall.enabled = true
