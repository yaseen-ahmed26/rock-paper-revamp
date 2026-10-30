extends Control

signal card_drag_started(card)
signal card_drag_ended(card)

@onready var icon: TextureRect = $Icon
@onready var suit: RichTextLabel = $Suit
@onready var weight: RichTextLabel = $Weight

@export var ui_handler: Node

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var home_position: Vector2 = Vector2.ZERO

var placeholder: Control = null
var original_parent: Node = null
var original_index: int = 0

# Juice & Animation
var target_rotation: float = 0.0
var original_scale: Vector2 = Vector2.ONE
var drop_tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	original_scale = scale
	pivot_offset = size / 2.0

func setup(card_base: CardBase, new_icon: Texture):
	self.visible = true
	self.name = str(card_base.id)
	
	icon.texture = new_icon
	suit.text = card_base.get_suit_name().to_upper()
	weight.text = "%s [%d]" % [CardBase.Weight.keys()[card_base.weight].to_upper(), card_base.weight]
		
	self.set_meta("CardBase", card_base.duplicate(true))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag()
		elif is_dragging:
			_end_drag()

	elif event is InputEventMouseMotion and is_dragging:
		var velocity_x = event.relative.x
		target_rotation = clampf(velocity_x * 0.03, deg_to_rad(-18.0), deg_to_rad(18.0))

func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset
		rotation = lerpf(rotation, target_rotation, 14.0 * delta)
		target_rotation = lerpf(target_rotation, 0.0, 8.0 * delta)

func _start_drag() -> void:
	is_dragging = true
	home_position = global_position
	drag_offset = get_global_mouse_position() - global_position
	original_parent = get_parent()
	original_index = get_index()
	
	var current_size = size
	
	# 1. Create a placeholder so the HBox doesn't collapse your hand
	placeholder = Control.new()
	placeholder.custom_minimum_size = current_size
	placeholder.size_flags_horizontal = size_flags_horizontal
	placeholder.size_flags_vertical = size_flags_vertical
	original_parent.add_child(placeholder)
	original_parent.move_child(placeholder, original_index)

	# 2. Break free from HBoxContainer layout and clipping boundaries
	top_level = true
	size = current_size
	global_position = home_position
	z_index = 100
	
	# Scale pop
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale * 1.08, 0.12)
	
	card_drag_started.emit(self)

func _end_drag() -> void:
	is_dragging = false
	var mouse_position: Vector2 = get_global_mouse_position()
	
	for area in get_tree().get_nodes_in_group("PlayerCardOutlines"):
		if area.is_visible_in_tree():
			var local_mouse: Vector2 = area.get_global_transform().affine_inverse() * mouse_position
			
			if Rect2(Vector2.ZERO, area.size).has_point(local_mouse):
				var slot_type := ""
				
				if "Lead" in area.name: slot_type = "lead"
				elif "Chain" in area.name: slot_type = "chain"
				elif "Special" in area.name: slot_type = "special"
				
				var card_base: CardBase = self.get_meta("CardBase")
				
				if ui_handler.try_play_card(card_base, slot_type):
					placeholder.queue_free()
					
					var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
					tween.tween_property(self, "modulate:a", 0.0, 0.2)
					await tween.finished
					
					self.queue_free()
					
					return
				break

	_return_to_hand()

func _return_to_hand() -> void:
	var target_pos = placeholder.global_position if is_instance_valid(placeholder) else home_position
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.22)
	tween.tween_property(self, "scale", original_scale, 0.2)
	tween.tween_property(self, "rotation", 0.0, 0.2)
	
	await tween.finished
	
	# Snap cleanly back into the HBoxContainer
	if is_instance_valid(placeholder):
		var target_idx = placeholder.get_index()
		placeholder.queue_free()
		placeholder = null
		
		top_level = false
		z_index = 0
		original_parent.move_child(self, target_idx)

func _play_drop_shake() -> void:
	if drop_tween:
		drop_tween.kill()
		
	rotation = 0.0
	scale = original_scale
	
	drop_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	drop_tween.tween_property(self, "scale", original_scale * 0.94, 0.05)
	drop_tween.tween_property(self, "scale", original_scale * 1.04, 0.06)
	drop_tween.tween_property(self, "scale", original_scale, 0.06)
