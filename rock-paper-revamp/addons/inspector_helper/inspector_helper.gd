@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object != null and not get_rules(object).is_empty()

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	var rules: Dictionary = get_rules(object)
	if not rules.has(name): return false
	
	var condition: String = rules[name]
	var should_show: bool = _eval_condition(object, condition)
	
	return not should_show

func get_rules(object: Object) -> Dictionary:
	var merged_rules: Dictionary = {}
	if not is_instance_valid(object): return merged_rules
		
	var script: Script = object.get_script()
	if not script: return merged_rules

	var current: Script = script
	
	while current != null:
		if "SHOW_IF" in current:
			var dict = current.get("SHOW_IF")
			
			if dict is Dictionary:
				_merge_dict_into_rules(dict, merged_rules)
		
		var g_name: String = current.get_global_name()
		
		if not g_name.is_empty():
			var custom_const: String = "SHOW_IF_" + g_name.to_upper()
			
			if custom_const in current:
				var dict = current.get(custom_const)
				
				if dict is Dictionary:
					_merge_dict_into_rules(dict, merged_rules)
					
		current = current.get_base_script()
		
	return merged_rules

func _merge_dict_into_rules(dict: Dictionary, out_rules: Dictionary) -> void:
	for k in dict:
		var v = dict[k]
		
		if v is Array:
			for prop in v:
				var prop_str = str(prop).strip_edges()
				
				if not out_rules.has(prop_str):
					out_rules[prop_str] = str(k).strip_edges()
		elif v is String:
			var prop_str = str(v).strip_edges()
			
			if not out_rules.has(prop_str):
				out_rules[prop_str] = str(k).strip_edges()

func _eval_condition(object: Object, condition: String) -> bool:
	var invert: bool = false
	var prop_name: String = condition
	
	if prop_name.begins_with("!"):
		invert = true
		prop_name = prop_name.substr(1).strip_edges()
	
	var val = bool(object.get(prop_name))
	
	return not val if invert else val
