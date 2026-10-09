extends Control

# Would eventually turn into reusable components

@onready var window_template_btn: Button = $VBoxContainer/WindowType/SelectWindowBtn/BtnHolder/TemplateButton

const WINDOW_TYPES: Array[String] = [
	"Fullscreen",
	"Window Mode",
	"Borderless Window",
	"Borderless Fullscreen"
]

var selected: String

func _ready() -> void:
	_create_window_btns()
	
 	#var saved_index: int = SaveManager.player.settings.get("WindowType")
	#selected = WINDOW_TYPES[saved_index]
	#$VBoxContainer/WindowType/SelectWindowBtn.text = selected

func _create_window_btns():
	for i in WINDOW_TYPES.size():
		var item = WINDOW_TYPES[i]
		
		var clone = window_template_btn.duplicate(true)
		$VBoxContainer/WindowType/SelectWindowBtn/BtnHolder.add_child(clone)
		
		clone.name = item.to_lower()
		clone.text = item
		clone.set_meta("Index", i)
		clone.visible = true
		
		clone.pressed.connect(_on_window_btn_pressed.bind(clone.get_meta("Index")))
	
func _on_window_btn_pressed(index: int):
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

	selected = WINDOW_TYPES[index]

func _on_select_window_btn_pressed():
	var btn: Button = $VBoxContainer/WindowType/SelectWindowBtn
	var btn_holder: VBoxContainer = btn.get_node("BtnHolder")
	
	if btn.get_meta("Open"):
		btn.set_meta("Open", false)
		btn_holder.visible = false
		btn.text = selected
	else:
		btn.set_meta("Open", true)
		btn_holder.visible = true
		btn.text = "CLOSE"

func _on_return_button_pressed() -> void:
	Signals.change_screen.emit("main_menu")
