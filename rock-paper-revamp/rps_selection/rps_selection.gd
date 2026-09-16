extends Control

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass

func _on_start_btn_pressed() -> void:
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode": "endless"
		}
	)
