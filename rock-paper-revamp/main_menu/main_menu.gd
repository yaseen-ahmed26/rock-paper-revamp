extends Control

@onready var menu_buttons: VBoxContainer = $MenuButtons

func _ready() -> void:
	for btn: Button in menu_buttons.get_children():
		btn.pressed.connect(_on_menu_btn_pressed.bind(btn))
		
func _on_menu_btn_pressed(btn: Button):
	match btn.name:
		"Play":
			Signals.change_screen.emit("rps_selection")
		"Quit":
			get_tree().quit()
