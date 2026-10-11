extends Panel

@export_category("Dropdown")
@export var label_text: String = "Label Text"
@export var description: String = "Description"

@onready var tick: TextureRect = $ToggleButton/Tick

signal checkbox_toggled()

var toggled: bool = false

func setup():
	$Label.text = label_text
	$DescriptionButton/Label.text = description

func enable():
	$ToggleButton.disabled = false

func disable(turn_off: bool = false):
	$ToggleButton.disabled = true
	
	if turn_off: _on_menu_btn_pressed()

func get_option():
	return toggled

func _on_menu_btn_pressed():	
	toggled = not toggled
	tick.visible = toggled
	
	checkbox_toggled.emit(toggled)

func _on_description_button_mouse_entered() -> void:
	$DescriptionButton/Label.visible = true
	
func _on_description_button_mouse_exited() -> void:
	$DescriptionButton/Label.visible = false
