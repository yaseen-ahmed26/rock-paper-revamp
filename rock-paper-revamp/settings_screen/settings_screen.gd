extends Control

@onready var window_type: Panel = $VBoxContainer/window_type
@onready var resolution: Panel = $VBoxContainer/resolution
@onready var v_sync: Panel = $VBoxContainer/v_sync
@onready var max_framerate: Panel = $VBoxContainer/max_framerate

var setting_callbacks: Dictionary[String, Callable] = {
	"window_type": _on_window_btn_pressed,
	"resolution": _on_resolution_btn_pressed,
	"max_framerate": _on_max_framerate_btn_pressed,
	"v_sync": _on_vsync_toggled,
	"icon_waterfall": _on_icon_waterfall_toggled,
}

func _ready() -> void:
	for k in SaveManager.local_saved_settings.keys():
		var v = SaveManager.local_saved_settings[k]
		
		var setting = $VBoxContainer.get_node_or_null(k)
		
		if setting:		
			var callback = setting_callbacks.get(k)
			
			if callback:
				if setting is SettingDropdown:
					callback.bind(v, setting.menu_correspondants).call()
				elif setting is SettingCheckbox:
					callback.bind(v).call()
				
				setting.setting_changed.connect(callback)			

			setting.setup(v)

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
		max_framerate.disable()
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		max_framerate.enable()
		max_framerate.force_specific_option()

func _on_max_framerate_btn_pressed(index: int, options: Array):
	Engine.max_fps = options[index]

func _on_icon_waterfall_toggled(_toggled: bool):
	pass

func _save_settings():
	var settings: Dictionary = {}
	
	for child in $VBoxContainer.get_children():
		settings[child.name] = child.get_option()
	
	SaveManager.save_settings(settings)

func _on_return_button_pressed() -> void:
	Signals.change_screen.emit("main_menu")
	_save_settings()
