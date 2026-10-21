@tool
extends EditorPlugin

const MODIFIER_SAVE_PATH: String = "res://content/cards/"

func _enter_tree() -> void:
	add_tool_menu_item("Create Cards", _create_modifier)

func _create_modifier():
	for k in CardBase.Suit.keys():
		if k == "NONE": continue
		
		var v = CardBase.Suit[k]
		var weight = CardBase.Weight.COLOSSAL
		var weight_lower = CardBase.Weight.keys()[weight].to_lower()
		
		var new := CardBase.new()
		
		new.suit = v
		new.weight = weight
		
		new.id = &"%s_%s" % [k.to_lower(), weight_lower]
		new.display_name = "%s (%s)" % [k.to_lower().capitalize(), weight_lower.capitalize()]
		new.description = "Suit: %s • Weight: %s" % [k.to_lower().capitalize(), weight_lower.capitalize()]
		
		ResourceSaver.save(new, MODIFIER_SAVE_PATH + "%s.tres" % str(new.id))
