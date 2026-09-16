extends Control

@export var gamemode_pool: Array[GamemodeBase]

@onready var gamemode_buttons: VBoxContainer = $GamemodeButtons
@onready var template_button: Button = $GamemodeButtons/TemplateButton

var selected_gamemode_btn: Button

func _ready() -> void:
	for gamemode in gamemode_pool:
		var clone: Button = template_button.duplicate(true)
		gamemode_buttons.add_child(clone)
		
		clone.name = gamemode.display_name.to_lower()
		clone.text = gamemode.display_name
		clone.visible = true
		clone.tooltip_text = gamemode.description
		
		clone.set_meta("Resource", gamemode)
		
		clone.pressed.connect(_on_gamemode_btn_pressed.bind(clone))

func _process(_delta: float) -> void:
	pass

func _on_gamemode_btn_pressed(btn: Button):
	if selected_gamemode_btn:
		selected_gamemode_btn.text = selected_gamemode_btn.get_meta("Resource").display_name
	
	$StartButton.disabled = false
	
	btn.text = "[>] " + btn.text
	selected_gamemode_btn = btn
	
func _on_start_btn_pressed() -> void:
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode_resource": selected_gamemode_btn.get_meta("Resource")
		}
	)
