extends Control

@onready var window_types: Panel = $VBoxContainer/WindowTypes
@onready var resolution: Panel = $VBoxContainer/Resolution
@onready var v_sync: Panel = $VBoxContainer/VSync
@onready var max_framerate: Panel = $VBoxContainer/MaxFramerate

func _ready() -> void:
	for child in $VBoxContainer.get_children():
		child.setup()
	
	window_types.option_btn_pressed.connect(_on_window_btn_pressed)
	resolution.option_btn_pressed.connect(_on_resolution_btn_pressed)
	v_sync.checkbox_toggled.connect(_on_vsync_toggled)
	max_framerate.option_btn_pressed.connect(_on_max_framerate_btn_pressed)

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

func _on_resolution_btn_pressed(index: int, options: Array):
	DisplayServer.window_set_size(options[index])

func _on_vsync_toggled(toggled: bool):
	if toggled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_max_framerate_btn_pressed(index: int, options: Array):
	Engine.max_fps = options[index]

func _on_return_button_pressed() -> void:
	Signals.change_screen.emit("main_menu")
