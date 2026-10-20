extends Panel

signal value_changed(new_value: float)

@onready var title_label: RichTextLabel = $TitleLabel
@onready var value_label: RichTextLabel = $CountLabel
@onready var minus_btn: Button = $MinusButton
@onready var plus_btn: Button = $PlusButton

var min_val: float = 1.0
var max_val: float = 99.0
var step: float = 1.0
var current_val: float = 1.0

func _ready() -> void:
	minus_btn.pressed.connect(_on_minus_pressed)
	plus_btn.pressed.connect(_on_plus_pressed)

func setup(label_text: String, start_val: float, p_min: float, p_max: float, p_step: float) -> void:
	title_label.text = label_text
	current_val = start_val
	min_val = p_min
	max_val = p_max
	step = p_step
	
	_refresh()

func _on_minus_pressed() -> void:
	current_val = clampf(current_val - step, min_val, max_val)
	
	_refresh()
	value_changed.emit(current_val)

func _on_plus_pressed() -> void:
	current_val = clampf(current_val + step, min_val, max_val)
	
	_refresh()
	value_changed.emit(current_val)

func _refresh() -> void:
	value_label.text = str(current_val)
	minus_btn.disabled = current_val <= min_val
	plus_btn.disabled = current_val >= max_val
