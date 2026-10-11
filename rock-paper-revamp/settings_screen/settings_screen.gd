extends Control

@onready var window_types: Panel = $VBoxContainer/WindowTypes
@onready var resolution: Panel = $VBoxContainer/Resolution
@onready var v_sync: Panel = $VBoxContainer/VSync

func _ready() -> void:
	window_types.setup()
	window_types.option_btn_pressed.connect(_on_window_btn_pressed)

	resolution.setup()
	resolution.option_btn_pressed.connect(_on_resolution_btn_pressed)

	v_sync.setup()
	v_sync.checkbox_toggled.connect(_on_vsync_toggled)

func _on_window_btn_pressed(index: int, _options: Array):
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _on_resolution_btn_pressed(index: int, options: Array[Vector2i]):
	DisplayServer.window_set_size(options[index])

func _on_vsync_toggled(toggled: bool):
	if toggled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_return_button_pressed() -> void:
	Signals.change_screen.emit("main_menu")
