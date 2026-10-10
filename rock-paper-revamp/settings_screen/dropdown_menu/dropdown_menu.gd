extends Panel

@export_category("Dropdown")
@export var label_text: String = "Label Text"
@export var description: String = "Description"
@export var open_btn_text: String = "Button Text"
@export var menu_options: Array[String] = []

@onready var template_button: Button = $MenuButton/BtnHolder/TemplateButton

signal option_btn_pressed(index: int)

func setup():
	$Label.text = label_text
	$MenuButton.text = open_btn_text
	$DescriptionButton/Label.text = description

	for i in menu_options.size():
		var item = menu_options[i]
		
		var clone = template_button.duplicate(true)
		$MenuButton/BtnHolder.add_child(clone)
		
		clone.name = item.to_lower()
		clone.text = item
		clone.set_meta("Index", i)
		clone.visible = true
		
		clone.pressed.connect(func(): option_btn_pressed.emit(clone.get_meta("Index")))

func _on_description_button_mouse_entered() -> void:
	$DescriptionButton/Label.visible = true
	
func _on_description_button_mouse_exited() -> void:
	$DescriptionButton/Label.visible = false
