extends Panel

@onready var template_button: Button = $TemplateButton

const TWEEN_CYCLE_LENGTH: float = 0.45

var selected_computer_btn: Button

func _ready() -> void:
	for opponent in ContentManager.computers.values():
		_create_btn(opponent)
	
	_select_opponent($Holder.get_children().pick_random())

func _create_btn(computer: ComputerBase):
	var clone: Button = template_button.duplicate(true)
	$Holder.add_child(clone)
	
	clone.name = computer.display_name.to_lower()
	clone.visible = true
	clone.tooltip_text = computer.description
	
	clone.get_node("OpponentName").text = computer.display_name
	clone.get_node("Description").text = computer.description
	
	clone.set_meta("Resource", computer.duplicate(true))
	
	clone.pressed.connect(_on_computer_btn_pressed.bind(clone))

func _select_opponent(btn: Button):
	var selected_label: RichTextLabel = btn.get_node("Selected")
	var opponent_name: RichTextLabel = btn.get_node("OpponentName")
	var description: RichTextLabel = btn.get_node("Description")

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(selected_label, "modulate:a", 1.0, TWEEN_CYCLE_LENGTH)
	tween.tween_property(opponent_name, "position", Vector2(48, 5), TWEEN_CYCLE_LENGTH)
	tween.tween_property(description, "modulate:a", 1.0, TWEEN_CYCLE_LENGTH)
	
	selected_computer_btn = btn
	
func _deselect_opponent(btn: Button):
	var selected_label: RichTextLabel = btn.get_node("Selected")
	var opponent_name: RichTextLabel = btn.get_node("OpponentName")
	var description: RichTextLabel = btn.get_node("Description")

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(selected_label, "modulate:a", 0.0, TWEEN_CYCLE_LENGTH)
	tween.tween_property(opponent_name, "position", Vector2(165, 5), TWEEN_CYCLE_LENGTH)
	tween.tween_property(description, "modulate:a", 0.0, TWEEN_CYCLE_LENGTH)

func _on_computer_btn_pressed(btn: Button):
	if selected_computer_btn:
		_deselect_opponent(selected_computer_btn)
		
	_select_opponent(btn)
	
func get_chosen_opponent():
	return selected_computer_btn.get_meta("Resource")
