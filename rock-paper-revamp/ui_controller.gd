extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var fade: ColorRect = $CanvasLayer/Fade

var current_screen: Control

func _ready() -> void:	
	current_screen = $CanvasLayer/main_menu
		
	Signals.change_screen.connect(_on_change_screen)
	
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
