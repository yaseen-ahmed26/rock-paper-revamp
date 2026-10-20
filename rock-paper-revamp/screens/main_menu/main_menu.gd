extends Control

@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var extra_buttons: HBoxContainer = $ExtraButtons
@onready var icon_waterfall: Control = $IconWaterfall

const MENU_BTNS: Dictionary = {
	"Play": "rps_selection",
	"Challenges": "challenge_selection",
	"Profile": "profile_screen",
	"Settings": "settings_screen"
}
const SIDE_BTNS: Dictionary = {
	"About": preload("res://custom_resources/modals/why_revamped.tres"),
	"Update": preload("res://custom_resources/modals/latest_update.tres"),
	# "Credits": "profile_screen",
	"Eyes": preload("res://custom_resources/modals/the_loop_explained.tres")
}

const EXTRA_MENU_OPEN_POSITION := Vector2(714, 673)
const EXTRA_MENU_HIDDEN_POSITION := Vector2(714, 613)

var redirect_modal = preload("res://custom_resources/modals/redirect_to_website.tres")
var confirm_sign_modal = preload("res://custom_resources/modals/confirm_sign_in.tres")
var refusal_no_internet = preload("res://custom_resources/modals/refusal_no_internet.tres")
var refusal_server_down = preload("res://custom_resources/modals/refusal_server_down.tres")

var extra_menu_open: bool = false

func _ready() -> void:
	for btn in menu_buttons.get_children():
		btn.pressed.connect(_on_menu_button_pressed.bind(btn))

	for btn in extra_buttons.get_children():
		btn.pressed.connect(_on_side_btn_pressed.bind(btn))
		btn.mouse_entered.connect(_on_side_btn_mouse_entered.bind(btn))
		btn.mouse_exited.connect(_on_side_btn_mouse_exited.bind(btn))


# Helpers
func _tween_extra_menu(final_position, final_modulate, final_mouse_filter):
	var all_descendants: Array = extra_buttons.find_children("*", "Button", true, false)
	
	for btn: Button in all_descendants:
		btn.mouse_filter = final_mouse_filter
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(extra_buttons, "position", final_position, 0.25) 
	tween.tween_property(extra_buttons, "modulate:a", final_modulate, 0.25)

# Button Connections
# Misc
func _on_extra_button_pressed():
	if extra_menu_open:
		_tween_extra_menu(
			EXTRA_MENU_HIDDEN_POSITION,
			0.0,
			Control.MOUSE_FILTER_IGNORE
		)
		$ExtraHoverLabel.visible = false
		$MenuButtons/Extra/Label.text = "Extra"
	else:
		_tween_extra_menu(
			EXTRA_MENU_OPEN_POSITION,
			1.0,
			Control.MOUSE_FILTER_STOP
		)
		$MenuButtons/Extra/Label.text = "CLOSE"
		
	extra_menu_open = not extra_menu_open
	
func _on_quit_pressed() -> void:
	get_tree().quit()

# Menu
func _on_menu_button_pressed(btn: Button):
	if btn.name == "Extra":
		_on_extra_button_pressed()
		return
		
	var screen_name = MENU_BTNS.get(btn.name)
	Signals.change_screen.emit(screen_name)
	
	await get_tree().create_timer(0.5).timeout	
	icon_waterfall.enabled = false

# Side
func _on_side_btn_mouse_entered(btn: Button):	
	if not extra_menu_open: return
	$ExtraHoverLabel.visible = true
	$ExtraHoverLabel.text = btn.name.capitalize()
	
func _on_side_btn_mouse_exited(_btn: Button):
	$ExtraHoverLabel.visible = false
	
func _on_side_btn_pressed(btn: Button):
	# Temporary exception
	if btn.name == "Credits":
		Signals.change_screen.emit("credits_screen")
		return
		
	var modal = SIDE_BTNS.get(btn.name)
	Signals.show_modal.emit(modal)

func _on_peck_button_pressed():
	if PeckManager.prevent_api_check:
		return
	elif PeckManager.no_internet:
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

# Signal Connections
func on_screen_change(_args):
	if SaveManager.local_saved_settings.get("icon_waterfall"):
		icon_waterfall.enabled = true
