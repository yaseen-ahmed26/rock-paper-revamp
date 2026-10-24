extends Control

@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var extra_buttons: HBoxContainer = $ExtraButtons
@onready var icon_waterfall: Control = $IconWaterfall
@onready var light: TextureRect = $Background/Light

const MENU_BTNS: Dictionary = {
	"Play": "rps_selection",
	"Challenges": "challenge_selection",
	"Profile": "profile_screen",
	"Settings": "settings_screen"
}
const SIDE_BTNS: Dictionary = {
	"About": preload("res://content/modals/why_revamped.tres"),
	"Update": preload("res://content/modals/latest_update.tres"),
	# "Credits": "profile_screen",
	"Eyes": preload("res://content/modals/the_loop_explained.tres")
}

const EXTRA_MENU_OPEN_POSITION := Vector2(714, 673)
const EXTRA_MENU_HIDDEN_POSITION := Vector2(714, 613)

const MENU_BTN_ICON_VISIBLE := Vector2(9, 9)

var redirect_modal = preload("res://content/modals/redirect_to_website.tres")
var confirm_sign_modal = preload("res://content/modals/confirm_sign_in.tres")
var refusal_no_internet = preload("res://content/modals/refusal_no_internet.tres")
var refusal_server_down = preload("res://content/modals/refusal_server_down.tres")

var open_carrot: Texture = preload("res://assets/icons/carrot_right.png")
var closed_carrot: Texture = preload("res://assets/icons/carrot_down.png")

var extra_menu_open: bool = false

var not_on_screen: bool = false

var icon_tween: Tween

func _ready() -> void:
	for btn in menu_buttons.get_children():
		btn.pressed.connect(_on_menu_button_pressed.bind(btn))

	for btn in extra_buttons.get_children():
		btn.pressed.connect(_on_side_btn_pressed.bind(btn))
		btn.mouse_entered.connect(_on_side_btn_mouse_entered.bind(btn))
		btn.mouse_exited.connect(_on_side_btn_mouse_exited.bind(btn))
	
	_tween_background_light()

# Helpers
func _tween_extra_menu(final_position, final_modulate, final_mouse_filter):
	var all_descendants: Array = extra_buttons.find_children("*", "Button", true, false)
	
	for btn: Button in all_descendants:
		btn.mouse_filter = final_mouse_filter
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(extra_buttons, "position", final_position, 0.25) 
	tween.tween_property(extra_buttons, "modulate:a", final_modulate, 0.25)

func _tween_background_light():
	if not_on_screen:
		return
	
	light.modulate.a = 1.0
	
	var pulse_tween: Tween = create_tween().set_loops()
	pulse_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	pulse_tween.tween_property(light, "modulate:a", randf_range(0.1, 0.3), 2.5)
	pulse_tween.tween_property(light, "modulate:a", randf_range(0.4, 0.7), 2.5)
	
	var move_tween: Tween = create_tween().set_loops()
	move_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	move_tween.tween_property(light, "position", Vector2(25, 75), 1.5).as_relative()
	move_tween.tween_property(light, "position", Vector2(-25, -75), 1.5).as_relative()

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
		$MenuButtons/Extra/Icon.texture = open_carrot
	else:
		_tween_extra_menu(
			EXTRA_MENU_OPEN_POSITION,
			1.0,
			Control.MOUSE_FILTER_STOP
		)
		$MenuButtons/Extra/Icon.texture = closed_carrot
		
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
	
	if extra_menu_open: _on_extra_button_pressed()
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	
	var icon: TextureRect = btn.get_node("Icon")
	
	tween.tween_property(
		icon, 
		"position", 
		icon.position + Vector2(200, 0), 
		0.6
	)
	
	await tween.finished
	icon_waterfall.enabled = false
	icon.position = MENU_BTN_ICON_VISIBLE

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

func _tween_menu_icons(icon: TextureRect):
	if icon_tween:
		await icon_tween.finished
		icon_tween = null
		
	icon.position = Vector2(50, 9)
		
	await get_tree().create_timer(randf_range(0.8, 1.1)).timeout
	
	icon_tween = create_tween()
	icon_tween.set_parallel(true)
	icon_tween.set_trans(Tween.TRANS_SINE)
	
	icon_tween.tween_property(icon, "position", MENU_BTN_ICON_VISIBLE, 0.6)
	icon_tween.tween_property(icon, "modulate:a", 1.0, 0.6)

func _animate_menu_elements():
	for btn in menu_buttons.get_children():
		if btn.name == "Extra": continue
		
		var icon: TextureRect = btn.get_node("Icon")
		
		_tween_menu_icons(icon)

# Signal Connections
func on_screen_change(_args):
	if SaveManager.local_saved_settings.get("icon_waterfall"):
		icon_waterfall.enabled = true
	
	await get_tree().create_timer(1.0).timeout
	_animate_menu_elements()
