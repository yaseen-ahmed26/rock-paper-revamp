extends RefCounted
class_name MoveStat

var display_text: String
var actual_move: String
var lock: bool = false
var visible: bool = true
var point_bonus: float = 0.0

func _init(p_text: String = "", p_move: String = "", p_enabled: bool = true, p_visible: bool = true, p_bonus: float = 0.0):
	display_text = p_text
	actual_move = p_move
	lock = p_enabled
	visible = p_visible
	point_bonus = p_bonus
