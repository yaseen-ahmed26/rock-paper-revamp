extends Panel

@export_category("Dropdown")
@export var label_text: String = "Label Text"
@export var description: String = "Description"
@export var open_btn_text: String = "Button Text"
@export var menu_options: Array[String] = []

@onready var template_button: Button = $TemplateButton
@onready var btn_holder: VBoxContainer = $MenuButton/BtnHolder

signal option_btn_pressed(index: int)

var selected_option: int

func setup(default_option: int = 0):
	$Label.text = label_text
	$MenuButton.text = open_btn_text
	$DescriptionButton/Label.text = description

	selected_option = default_option

	for i in menu_options.size():
		var item = menu_options[i]
		
		var clone = template_button.duplicate(true)
		$MenuButton/BtnHolder.add_child(clone)
		
		clone.name = item.to_lower()
		clone.text = item
		clone.set_meta("Index", i)
		clone.visible = true
		
		clone.pressed.connect(_on_option_btn_pressed.bind(clone))

func _on_option_btn_pressed(btn: Button):
	var index = btn.get_meta("Index")
	
	$MenuButton.text = btn.text
	selected_option = index
	
	option_btn_pressed.emit(index)

func _on_menu_btn_pressed():
	var btn = $MenuButton
	var open = btn.get_meta("Open")
	
	if open:
		btn.set_meta("Open", false)
		btn_holder.visible = false
		
		btn.text = btn_holder.get_child(selected_option).name.capitalize()
	else:
		btn.set_meta("Open", true)
		btn_holder.visible = true
		
		btn.text = "CLOSE"

func _on_description_button_mouse_entered() -> void:
	$DescriptionButton/Label.visible = true
	
func _on_description_button_mouse_exited() -> void:
	$DescriptionButton/Label.visible = false
