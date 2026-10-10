@tool
extends EditorPlugin

const MODIFIER_SAVE_PATH: String = "res://custom_resources/modifiers/"
const RESOURCE_HELPER_DIALOG = preload("uid://duvwhcdbpr5bw")

func _enter_tree() -> void:
	add_tool_menu_item("Create Modifier", _create_modifier)

func _create_modifier():
	var dialog = RESOURCE_HELPER_DIALOG.instantiate()
	EditorInterface.get_base_control().add_child(dialog)
	
	dialog.popup_centered()
	dialog.confirmed.connect(_on_dialog_confirmed.bind(dialog))

func _on_dialog_confirmed(dialog: ConfirmationDialog):
	var data = dialog.get_data()
	var modifier_base: ModifierBase = ModifierBase.new()
	
	modifier_base.display_name = data.get("name")
	modifier_base.description = data.get("description")
	modifier_base.id = data.get("id")
	
	modifier_base.one_shot = data.get("one_shot")
	modifier_base.exclude_badge = data.get("exclude_badge")
	
	modifier_base.tier = data.get("tier")
	
	if data["purchase"]["required"]:
		modifier_base.requires_purchase = true
		modifier_base.purchase_cost = data["purchase"].get("cost")
	elif data["challenge"]["required"]:
		modifier_base.challenge_required = true
		modifier_base.challenge_id = data["challenge"].get("id")
	
	for i in data.get("number_of_rules"):
		modifier_base.rules.append(ModifierRule.new())
		
	for i in data.get("stat_changes"):
		modifier_base.starting_stat_changes.append(StatChange.new())
	
	if data.get("has_internal"):
		modifier_base.has_internal = true
		modifier_base.internal_state = ModifierInternal.new()
	
	ResourceSaver.save(modifier_base, MODIFIER_SAVE_PATH + "%s.tres" % str(modifier_base.id))

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
