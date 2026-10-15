extends Panel

@onready var template_button: Button = $ScrollContainer/Holder/TemplateButton

const MAX_AMOUNT_MODIFIERS: int = 3
const TIER_DETAILS: Dictionary = {
	1: "Free",
	2: "Basic",
	3: "Legacy",
	4: "Advanced",
	5: "Special",
}

var WHITE_BORDER: Color = Color("616161")
var BLUE_BORDER: Color = Color("3364ff")

var selected_modifier_btns: Array[Button] = []

func _ready() -> void:
	_sort_modifiers()
	
	for btn in $SelectedModifiers.get_children():
		btn.pressed.connect(_on_modifier_info_btn_pressed.bind(btn))

func _create_btn(modifier: ModifierBase, parent):
	var clone: Button = template_button.duplicate(true)
	parent.add_child(clone)
	
	clone.name = modifier.display_name.to_lower()
	clone.visible = true
	clone.tooltip_text = modifier.description
	
	var info_rect: ColorRect = clone.get_node("Info")
	var locked_rect: ColorRect = clone.get_node("Locked")
	var purchase_rect: ColorRect = clone.get_node("Purchase")

	info_rect.get_node("ModifierName").text = modifier.display_name
	
	if modifier.icon:
		info_rect.get_node("Icon").texture = modifier.icon
	
	clone.set_meta("Resource", modifier.duplicate(true))
	clone.set_meta("Locked", false)
	
	if modifier.challenge_required:			
		var completed_challenges: Array = SaveManager.local_saved_data.get("completed_challenges", [])
		
		if completed_challenges.is_empty():
			locked_rect.visible = true
			clone.set_meta("Locked", true)
		else:
			if not modifier.challenge_id in completed_challenges:
				locked_rect.visible = true
				clone.set_meta("Locked", true)
	elif modifier.requires_purchase:				
		if not modifier.id in SaveManager.local_saved_data.get("bought_modifiers"):						
			var buy_button = purchase_rect.get_node("BuyButton")
			
			purchase_rect.visible = true
			buy_button.text = "%d Tokens" % modifier.purchase_cost
			
			buy_button.pressed.connect(_on_buy_modifier_pressed.bind(clone))
			clone.set_meta("Locked", true)
		
	clone.pressed.connect(_on_modifier_btn_pressed.bind(clone))

func _reset_btn_style(btn: Button):
	var existing_stylebox: StyleBoxFlat = btn.get_theme_stylebox("normal")
	var duplicate_stylebox: StyleBoxFlat = existing_stylebox.duplicate()

	duplicate_stylebox.border_color = WHITE_BORDER
	btn.add_theme_stylebox_override("normal", duplicate_stylebox)

func _update_info_btns():
	for btn: Button in $SelectedModifiers.get_children():
		var btn_position: int = btn.get_meta("Position")

		if (btn_position + 1) > selected_modifier_btns.size():
			btn.text = "[ EMPTY ]"
			btn.disabled = true
			btn.get_node("NumberLabel").visible = false
			
			continue
			
		var modifier_btn = selected_modifier_btns[btn_position]
		var info: ModifierBase = modifier_btn.get_meta("Resource")
		
		btn.text = info.display_name
		btn.disabled = false
		
		btn.get_node("NumberLabel").visible = true
		btn.set_meta("ModifierBase", info)

	var total_modifiers: int = selected_modifier_btns.size()

	$SelectedHeading/Counter.text = "[color=%s][%d/%d]" % [
		"red" if total_modifiers == 3 else "green" if total_modifiers <= 2 and total_modifiers > 0 else "white",
		total_modifiers, 
		MAX_AMOUNT_MODIFIERS
	]

func _sort_modifiers() -> void:
	var tiers: Dictionary = {}
	
	for mod in ContentManager.modifiers.values():
		if not tiers.has(mod.tier):
			tiers[mod.tier] = []
		
		tiers[mod.tier].append(mod)

	var root_vbox = $ScrollContainer/Holder
	var sorted_tiers = tiers.keys()
	sorted_tiers.sort()

	for t in sorted_tiers:
		var header := Label.new()
		header.text = "TIER %d • [ %s ]" % [t, TIER_DETAILS.get(t)]
		header.add_theme_font_size_override("font_size", 20)
		root_vbox.add_child(header)

		var grid := GridContainer.new()
		grid.columns = 5
		
		grid.add_theme_constant_override("h_separation", 15)
		grid.add_theme_constant_override("v_separation", 15)
		
		root_vbox.add_child(grid)

		for mod in tiers[t]:
			_create_btn(mod, grid)

func _on_modifier_btn_pressed(btn: Button):
	var existing_stylebox: StyleBoxFlat = btn.get_theme_stylebox("normal")
	var duplicate_stylebox: StyleBoxFlat = existing_stylebox.duplicate()
	var selected_panel = btn.get_node("SelectedPanel")
	
	if selected_modifier_btns.has(btn):
		selected_modifier_btns.erase(btn)
		selected_panel.visible = false
		
		_reset_btn_style(btn)
	else:
		if selected_modifier_btns.size() == MAX_AMOUNT_MODIFIERS: return
		
		selected_modifier_btns.append(btn)
		
		selected_panel.visible = true
		duplicate_stylebox.border_color = BLUE_BORDER
		btn.add_theme_stylebox_override("normal", duplicate_stylebox)
		
	_update_info_btns()

func _on_reset_modifiers_pressed():
	for btn in selected_modifier_btns:
		btn.get_node("SelectedPanel").visible = false
		_reset_btn_style(btn)
	
	selected_modifier_btns.clear()
	
	_update_info_btns()
	
	$ResetModifiers.text = "✓"
	$ResetModifiers/Icon.visible = false
	await get_tree().create_timer(1.2).timeout
	$ResetModifiers.text = "[ RESET ]"
	$ResetModifiers/Icon.visible = true

func _on_search_bar_text_changed(new_text: String) -> void:
	var query: String = new_text.to_lower().strip_edges()
	
	var all_descendants: Array[Node] = $ScrollContainer/Holder.find_children("*", "Button", true, false)
	
	for child in all_descendants:		
		if child.name == "TemplateButton": continue
		if child.name == "BuyButton": continue
		
		if query == "":
			child.visible = true
		else:
			child.visible = query in child.name.capitalize().to_lower()

func _on_buy_modifier_pressed(btn: Button) -> void:
	if PlayerManager.purchase_modifier(btn.get_meta("Resource")):
		btn.set_meta("Locked", false)

		var purchase = btn.get_node("Purchase")
		
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(purchase, "position", purchase.position + Vector2(0, 100), 0.4)
		tween.tween_property(purchase, "modulate:a", 0.0, 0.4)
		await tween.finished
		purchase.visible = false

func _on_modifier_info_btn_pressed(btn: Button):
	var modifier_screen: Panel = $"../Overlay/Modifier"
	
	modifier_screen.get_node("Title").text = btn.get_meta("ModifierBase").display_name
	modifier_screen.get_node("Description").text = btn.get_meta("ModifierBase").description
	
	owner.show_overlay(modifier_screen)

func _on_filter_modifier_btn_pressed():
	owner.show_overlay($"../Overlay/FilterModifiers")

func _on_filter_locked_btn_pressed():
	var all_descendants: Array[Node] = $ScrollContainer/Holder.find_children("*", "Button", true, false)
	
	for child in all_descendants:
		if child.name == "TemplateButton": continue
		if child.name == "BuyButton": continue
		
		if child.get_meta("Locked"):
			child.visible = true
		else:
			child.visible = false
		
func _on_filter_unlocked_btn_pressed():
	var all_descendants: Array[Node] = $ScrollContainer/Holder.find_children("*", "Button", true, false)
	
	for child in all_descendants:
		if child.name == "TemplateButton": continue
		if child.name == "BuyButton": continue

		if child.get_meta("Locked"):
			child.visible = false
		else:
			child.visible = true

func _on_clear_filters_pressed():
	var all_descendants: Array[Node] = $ScrollContainer/Holder.find_children("*", "Button", true, false)
	
	for child in all_descendants:
		if child.name == "TemplateButton": continue
		if child.name == "BuyButton": continue

		child.visible = true

func check_unlocks():
	var all_descendants: Array[Node] = $ScrollContainer/Holder.find_children("*", "Button", true, false)
	
	for child in all_descendants:
		if child.name == "TemplateButton": continue
		if child.name == "BuyButton": continue
		
		var modifier: ModifierBase = child.get_meta("Resource")
		
		if not modifier.challenge_required: continue

		var completed_challenges: Array = SaveManager.local_saved_data.get("completed_challenges", [])
		
		if modifier.challenge_id in completed_challenges:
			child.get_node("Locked").visible = false
			child.set_meta("Locked", false)

func get_chosen_modifiers() -> Array[ModifierBase]:
	var modifiers: Array[ModifierBase] = []
	
	for btn: Button in selected_modifier_btns:
		var resource = btn.get_meta("Resource")
		modifiers.append(resource)
		
	return modifiers
