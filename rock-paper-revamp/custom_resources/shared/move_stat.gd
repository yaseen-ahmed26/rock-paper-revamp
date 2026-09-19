extends RefCounted
class_name MoveStat

var display_text: String
var actual_move: String
var enabled: bool = true
var visible: bool = true

func _init(p_text: String = "", p_move: String = "", p_enabled: bool = true, p_visible: bool = true):
	display_text = p_text
	actual_move = p_move
	enabled = p_enabled
	visible = p_visible
