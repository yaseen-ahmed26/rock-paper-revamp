extends Panel

@export var keybind: String

@onready var key: RichTextLabel = $Key

func _ready() -> void:
	key.text = keybind
