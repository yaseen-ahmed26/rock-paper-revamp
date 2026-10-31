extends Control

@onready var display_settings_holder: Control = $SettingsHolder/Display
@onready var setting_template: Button = $SettingsHolder/Template
@onready var selected_setting: Panel = $SelectedSetting
@onready var preferences_settings_holder: Control = $SettingsHolder/Preferences

var settings: Dictionary = {
	"window_type": {
		"icon": null,
		"description": "Change your window type.",
		"options": [
			"Fullscreen", "Windowed", "Borderless Window", "Borderless Fullscreen"
		],
		"data": [
			[DisplayServer.WINDOW_MODE_FULLSCREEN, false],
			[DisplayServer.WINDOW_MODE_WINDOWED, false],
			[DisplayServer.WINDOW_MODE_WINDOWED, true],
			[DisplayServer.WINDOW_MODE_FULLSCREEN, true]
		],
		"summary": "[color=#a855f7]• Windowed:[/color] Desc goes here\n[color=#a855f7]• Fullscreen:[/color] Big screen
		",
		"callback": _window_setting_changed,
		"parent": "display",
		"current_option": 0,
		"default_option": 0,
	},
	"resolution": {
		"icon": null,
		"description": "Set the size of the window.",
		"options": [
			"1152 x 648", "1280 x 720", "1920 x 1080"
		],
		"data": [
			Vector2(1152, 648),
			Vector2(1280, 720),
			Vector2(1920, 1080),
		],
		"summary": "",
		"callback": _resolution_setting_changed,
		"parent": "display",
		"current_option": 2,
		"default_option": 2,
	},
	"max_framerate": {
		"icon": null,
		"description": "Set the max amount of framerate.",
		"options": [
			"Unlimited", "30 FPS", "60 FPS", "120 FPS"
		],
		"data": [
			0, 30, 60, 120
		],
		"summary": "",
		"callback": _max_framerate_setting_changed,
		"parent": "display",
		"current_option": 2,
		"default_option": 2,
	},
	"v_sync": {
		"icon": null,
		"description": "Synchronize rendered frames with your monitor's refresh rate.",
		"options": [
			"Disabled", "Enabled", "Adaptive", "Mailbox"
		],
		"data": [
			DisplayServer.VSYNC_DISABLED,
			DisplayServer.VSYNC_ENABLED,
			DisplayServer.VSYNC_ADAPTIVE,
			DisplayServer.VSYNC_MAILBOX
		],
		"summary": "[color=#a855f7]• Disabled:[/color] Lowest input lag, may cause screen tearing.\n[color=#a855f7]• Enabled:[/color] Smooth frame delivery, eliminates tearing.\n[color=#a855f7]• Adaptive:[/color] Enables VSync at high framerates, turns off if FPS drops below refresh rate.\n[color=#a855f7]• Mailbox:[/color] Renders unconstrained while always presenting the newest frame (ultra-low latency, no tear).",
		"callback": _vsync_setting_changed,
		"parent": "display",
		"current_option": 0,
		"default_option": 0,
	},
	"skip_splash": {
		"icon": null,
		"description": "Skip the splash screen automatically when the game starts up.",
		"options": [
			"Disabled", "Enabled"
		],
		"data": [
			false, true
		],
		"summary": "[color=#a855f7]• Enabled:[/color] Skips the splash screen when the game starts automatically.\n[color=#a855f7]• Disabled:[/color] Plays the entire sequence unless manually skipped.",
		"callback": _skip_splash_setting_changed,
		"parent": "preferences",
		"current_option": 0,
		"default_option": 0,
	},
	"icon_waterfall": {
		"icon": null,
		"description": "Show icons falling on the main menu.",
		"options": [
			"Disabled", "Enabled"
		],
		"data": [
			false, true
		],
		"summary": "",
		"callback": _icon_waterfall_setting_changed,
		"parent": "preferences",
		"current_option": 1,
		"default_option": 1,
	},
}
const OPTION_NORMAL_BTN = preload("uid://xohovlaokuyr")
const OPTION_SELECTED_BTN = preload("uid://dv7a413xxcty6")
const TAB_NORMAL_BTN = preload("uid://tlq20m2hkd56")
const TAB_SELECTED_BTN = preload("uid://bof34ag6ttno6")

var current_tab: Control

func _ready() -> void:
	for btn in $TopBar/Tabs.get_children():
		btn.pressed.connect(_on_tab_btn_pressed.bind(btn))
	
	current_tab = display_settings_holder
	
	_create_holder_btns()
	
func _create_holder_btns():
	for k in settings:
		var v = settings[k]
		
		v.current_option = SaveManager.local_saved_settings.get(k)
				
		var clone: Button = setting_template.duplicate(true)
			
		match v.parent:
			"display": display_settings_holder.get_node("Holder").add_child(clone)
			"preferences": preferences_settings_holder.get_node("Holder").add_child(clone)
		
		clone.visible = true
		clone.name = k
		
		if v.icon:
			clone.get_node("Icon").texture = v.icon
	
		clone.get_node("Label").text = "%s\n[font_size=13][color=#94a3b8]%s[/color][/font_size]" % [
			k.to_upper().replace("_", " "),
			v.description
		]
		clone.get_node("SelectedOption/Label").text = v.options.get(SaveManager.local_saved_settings.get(k))

		clone.pressed.connect(_update_inspector.bind(k))

		v.callback.call(SaveManager.local_saved_settings.get(k))
	
	_update_inspector("window_type")

func _update_holder_btn(setting_name: String):
	var details = settings.get(setting_name)
	
	var parent: Control
	
	match details.parent:
		"display": parent = display_settings_holder
		"preferences": parent = preferences_settings_holder
	
	var btn: Button = parent.get_node("Holder").get_node(setting_name)
	
	if btn:
		btn.get_node("SelectedOption/Label").text = details.options[details.current_option]

func _update_inspector(setting_name: String):
	var details: Dictionary = settings.get(setting_name)
	var holder: VBoxContainer = selected_setting.get_node("Holder")
	
	selected_setting.get_node("SettingName").text = setting_name.replace("_", " ").capitalize()
	selected_setting.get_node("Summary/Label").text = details.summary
	
	for child: Button in holder.get_children():
		var name_int: int = int(child.name)
		
		if name_int >= details.options.size():
			child.visible = false
			continue
		
		child.visible = true
		child.add_theme_stylebox_override("normal", OPTION_NORMAL_BTN)
		child.get_node("Label").text = details.options.get(name_int)
		child.get_node("ActiveBadge").visible = false
		child.get_node("SelectBadge").visible = true
		
		for connection in child.pressed.get_connections():
			child.pressed.disconnect(connection.callable)
		
		child.pressed.connect(func(): 
			var selected_btn: Button = holder.get_child(details.current_option)
			selected_btn.add_theme_stylebox_override("normal", OPTION_NORMAL_BTN)
			selected_btn.get_node("ActiveBadge").visible = false
			selected_btn.get_node("SelectBadge").visible = true

			child.add_theme_stylebox_override("normal", OPTION_SELECTED_BTN)			
			child.get_node("ActiveBadge").visible = true
			child.get_node("SelectBadge").visible = false
			
			details.current_option = name_int
			details.callback.call(name_int)
			
			_update_holder_btn(setting_name)
		)
		
		if name_int == details.current_option:
			child.add_theme_stylebox_override("normal", OPTION_SELECTED_BTN)
			child.get_node("ActiveBadge").visible = true
			child.get_node("SelectBadge").visible = false

# Setting Functions
func _window_setting_changed(chosen_index: int):	
	var details: Dictionary = settings.get("window_type")
	var info: Array = details.data.get(chosen_index)
	
	DisplayServer.window_set_mode(info[0])
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, info[1])

func _resolution_setting_changed(chosen_index: int):
	var details: Dictionary = settings.get("resolution")
	DisplayServer.window_set_size(details.data.get(chosen_index))

func _max_framerate_setting_changed(chosen_index: int):
	var details: Dictionary = settings.get("max_framerate")
	Engine.max_fps = details.data[chosen_index]

func _vsync_setting_changed(chosen_index: int):
	var details: Dictionary = settings.get("v_sync")
	var mode: DisplayServer.VSyncMode = details.data[chosen_index]
	DisplayServer.window_set_vsync_mode(mode)

func _skip_splash_setting_changed(_chosen_index: int):
	pass
	
func _icon_waterfall_setting_changed(_chosen_index: int):
	pass

# Button Connections
func _on_tab_btn_pressed(btn: Button):
	var found_tab: Control = $SettingsHolder.get_node_or_null(str(btn.name))
	
	if found_tab:
		var old_btn: Button = $TopBar/Tabs.get_node(str(current_tab.name))
		old_btn.add_theme_stylebox_override("normal", TAB_NORMAL_BTN)
		
		btn.add_theme_stylebox_override("normal", TAB_SELECTED_BTN)
		
		current_tab.visible = false
		found_tab.visible = true
		current_tab = found_tab
		
		var first_child: String = found_tab.get_node("Holder").get_child(0).name
		_update_inspector(first_child)
		
# Saving
func _save_settings():
	var settings_to_save: Dictionary = {}
	
	for k in settings.keys():
		var v = settings[k]
		settings_to_save[k] = v.current_option
	
	SaveManager.save_settings(settings_to_save)

func _on_return_button_pressed() -> void:
	Signals.change_screen.emit("main_menu")
	_save_settings()
