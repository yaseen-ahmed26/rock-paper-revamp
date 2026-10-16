extends Control

@onready var overlay: ColorRect = $Overlay
@onready var tokens: Panel = $Tokens

var current_overlay: Panel

func _ready() -> void:
	tokens.get_node("Label").text = str(int(SaveManager.local_saved_data.get("tokens")))		
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				if current_overlay and overlay.visible:				
					_on_close_overlay_pressed()

# Overlay
func show_overlay(screen: Panel):
	if current_overlay:
		current_overlay.visible = false
		
		var old_btns: Array[Node] = current_overlay.find_children("*", "Button", true, false)
		
		for btn: Button in old_btns:
			btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	current_overlay = screen
	screen.visible = true
	
	var all_descendants: Array[Node] = screen.find_children("*", "Button", true, false)
	
	for btn in all_descendants:
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
	await tween.finished
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	$Overlay/CloseOverlay.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_close_overlay_pressed() -> void:
	var old_btns: Array[Node] = current_overlay.find_children("*", "Button", true, false)
		
	for btn: Button in old_btns:
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
	await tween.finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Overlay/CloseOverlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Button Connections
func _on_token_info_button_pressed():
	show_overlay($Overlay/Tokens)
	
func _on_return_btn_pressed():
	Signals.change_screen.emit("main_menu")

func _on_start_btn_pressed() -> void:
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode_resource": $Gamemodes.get_chosen_gamemode(),
			"modifier_resource": $Modifiers.get_chosen_modifiers(),
			"computer_resource": $Opponents.get_chosen_opponent(),
		}
	)

func on_screen_change(_args):
	tokens.get_node("Label").text = str(int(SaveManager.local_saved_data.get("tokens")))		
		
	$Modifiers.check_unlocks()
