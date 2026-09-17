extends Control

@export var gamemode_pool: Array[GamemodeBase]
@export var modifier_pool: Array[ModifierBase]

@onready var template_button: Button = $TemplateButton

var selected_gamemode_btn: Button
var selected_modifier_btn: Button

func _ready() -> void:
	for gamemode in gamemode_pool:
		create_btn(gamemode, $GamemodeButtons)
		
	for modifier in modifier_pool:
		create_btn(modifier, $ModifierButtons)

func _process(_delta: float) -> void:
	pass

# Helpers
func create_btn(info, parent):
	var clone: Button = template_button.duplicate(true)
	parent.add_child(clone)
	
	clone.name = info.display_name.to_lower()
	clone.text = info.display_name
	clone.visible = true
	clone.tooltip_text = info.description
	
	clone.set_meta("Resource", info)
	
	if parent == $GamemodeButtons:
		clone.pressed.connect(_on_gamemode_btn_pressed.bind(clone))
	else:
		clone.pressed.connect(_on_modifier_btn_pressed.bind(clone))

# Button & Signal Connections
func _on_gamemode_btn_pressed(btn: Button):
	if selected_gamemode_btn:
		selected_gamemode_btn.text = selected_gamemode_btn.get_meta("Resource").display_name
	
	$StartButton.disabled = false
	
	btn.text = "[>] " + btn.text
	selected_gamemode_btn = btn

func _on_modifier_btn_pressed(btn: Button):
	if selected_modifier_btn:
		selected_modifier_btn.text = selected_modifier_btn.get_meta("Resource").display_name
		
	btn.text = "[>] " + btn.text
	selected_modifier_btn = btn

func _on_start_btn_pressed() -> void:
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode_resource": selected_gamemode_btn.get_meta("Resource"),
			"modifier_resource": selected_modifier_btn.get_meta("Resource")
		}
	)
