extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var fade: ColorRect = $CanvasLayer/Fade
@onready var continue_button: Button = $CanvasLayer/Modal/Background/Buttons/ContinueButton
@onready var cancel_button: Button = $CanvasLayer/Modal/Background/Buttons/CancelButton
@onready var modal: Panel = $CanvasLayer/Modal

var current_screen: Control

func _ready() -> void:	
	current_screen = $CanvasLayer/main_menu
	
	continue_button.pressed.connect(_on_option_btn_pressed.bind(continue_button))
	cancel_button.pressed.connect(_on_option_btn_pressed.bind(cancel_button))
	
	Signals.change_screen.connect(_on_change_screen)
	Signals.show_modal.connect(_on_show_modal)
	
func _on_change_screen(to_show: String, arguments: Variant = null):
	fade.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	
	var new_screen = canvas_layer.get_node_or_null(to_show)
	
	if not new_screen:
		print("'%s' scene was not found" % to_show)
		return
		
	var tween_in: Tween = create_tween()
	tween_in.tween_property(fade, "self_modulate:a", 1.0, 0.5)
	await tween_in.finished

	current_screen.visible = false
	new_screen.visible = true
	
	if new_screen.has_method("on_screen_change"):
		new_screen.call("on_screen_change", arguments)
	
	current_screen = new_screen
	
	await get_tree().create_timer(1.0).timeout
	
	var tween_out: Tween = create_tween()
	tween_out.tween_property(fade, "self_modulate:a", 0.0, 0.5)
	await tween_out.finished
	
	fade.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

func _on_show_modal(modal_base: ModalBase, details: Array = []):
	modal.mouse_filter = Control.MOUSE_FILTER_STOP
	
	modal.get_node("Background/Title").text = modal_base.title
	modal.get_node("Background/Primary").text = modal_base.primary_text
	modal.get_node("Background/Secondary").text = modal_base.secondary_text
	continue_button.text = modal_base.continue_btn_text
	
	continue_button.mouse_filter = Control.MOUSE_FILTER_STOP
	modal.get_node("Background/Secondary").mouse_filter = Control.MOUSE_FILTER_STOP
	
	if not details.is_empty():
		modal.get_node("Background/Primary").text = modal.get_node("Background/Primary").text % details
		
	if not modal_base.show_cancel_btn:
		cancel_button.visible = false
	else:
		cancel_button.text = modal_base.cancel_btn_text
		cancel_button.visible = true
	
	var tween_in: Tween = create_tween()
	tween_in.tween_property(modal, "modulate:a", 1.0, 0.5)

func _on_option_btn_pressed(btn: Button):
	if btn == continue_button:
		Signals.modal_response.emit(true)
	else:
		Signals.modal_response.emit(false)
	
	var tween_out: Tween = create_tween()
	tween_out.tween_property(modal, "modulate:a", 0.0, 0.5)
	
	await tween_out.finished
	
	continue_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal.get_node("Background/Secondary").mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_secondary_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
