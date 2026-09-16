@tool
extends EditorPlugin

var inspector_plugin

func _enter_tree() -> void:
	inspector_plugin = preload("res://addons/inspector_helper/inspector_helper.gd").new()
	add_inspector_plugin(inspector_plugin)
	
	EditorInterface.get_inspector().property_edited.connect(_on_property_edited)

func _exit_tree() -> void:
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
	
	if EditorInterface.get_inspector().property_edited.is_connected(_on_property_edited):
		EditorInterface.get_inspector().property_edited.disconnect(_on_property_edited)

func _on_property_edited(property_name: String) -> void:
	var obj = EditorInterface.get_inspector().get_edited_object()
	
	if not is_instance_valid(obj): return
	if not inspector_plugin or not inspector_plugin.has_method("get_rules"): return
		
	var rules: Dictionary = inspector_plugin.get_rules(obj)
	
	for target_prop in rules:
		var cond_prop: String = str(rules[target_prop]).strip_edges().trim_prefix("!")
		
		if cond_prop == property_name:
			obj.notify_property_list_changed()
			
			break
