extends Panel

@export var keybind: String

@onready var key: RichTextLabel = $Key

func _ready() -> void:
	key.text = keybind
	
	if keybind.length() >= 4:
		key.add_theme_font_size_override("normal_font_size", 14)
	else:
		key.add_theme_font_size_override("normal_font_size", 22)
