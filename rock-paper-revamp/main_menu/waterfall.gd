extends Control

@export var enabled: bool = true
@export var icons: Array[Texture2D] = []

var spawn_interval: float = 0.3
var min_speed: float = 140.0
var max_speed: float = 280.0
var min_scale: float = 0.7
var max_scale: float = 1.1

var column_width: float = 1080.0
var timer: float = 0.0

func _process(delta: float) -> void:
	if not enabled: return
	
	timer += delta	
	
	if timer >= spawn_interval:		
		timer = 0.0		
		_spawn_icon()
	
	var screen_h = get_viewport_rect().size.y
		
	for child in get_children():
		if child.name == "IconTemplate": continue
			
		var speed = child.get_meta("speed")		
		var rot_speed = child.get_meta("rot_speed")
		
		child.position.y += speed * delta		
		child.rotation += rot_speed * delta
		
		if child.position.y > screen_h + 100.0:			
			child.queue_free()
			
func _spawn_icon() -> void:	
	var rect = $IconTemplate.duplicate()
	
	rect.texture = icons.pick_random()	

	var s = randf_range(min_scale, max_scale)	
	rect.scale = Vector2(s, s)	
	rect.set_meta("speed", randf_range(min_speed, max_speed))	
	rect.set_meta("rot_speed", randf_range(-1.5, 1.5))

	var screen_w = get_viewport_rect().size.x	
	var spawn_x: float	
	
	if randf() < 0.5:		
		spawn_x = randf_range(20.0, column_width)	
	else:		
		spawn_x = randf_range(screen_w - column_width, screen_w - 20.0)
	
	rect.position = Vector2(spawn_x, -120.0)	
	add_child(rect)
	
