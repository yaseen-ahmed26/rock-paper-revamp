extends Control

@export var gamemode_pool: Array[GamemodeBase]
@export var modifier_pool: Array[ModifierBase]
@export var computer_pool: Array[ComputerBase]

@onready var gm_btn_holder: VBoxContainer = $Gamemodes/PickGamemodeBtn/BtnHolder
@onready var info_buttons: HBoxContainer = $Modifiers/InfoButtons
@onready var overlay: ColorRect = $Overlay

var selected_gamemode: GamemodeBase

var selected_modifier_btns: Array[Button] = []
var selected_computer_btn: Button

var locked_modifiers: Dictionary = {}

# Godot
func _ready() -> void:
	$Tokens.text = "Tokens: " + str(int(SaveManager.save_data.get("tokens")))
	
	for gamemode in gamemode_pool:
		_create_btn(
			gamemode,
			gm_btn_holder,
			$Gamemodes/PickGamemodeBtn/BtnHolder/TemplateButton,
			_on_gamemode_btn_pressed
		)
		
	for modifier in modifier_pool:
		_create_btn(
			modifier,
			$Modifiers/ScrollContainer/Holder,
			$Modifiers/ScrollContainer/Holder/TemplateButton,
			_on_modifier_btn_pressed
		)
		
	for computer in computer_pool:
		_create_btn(
			computer,
			$Computers/Holder,
			$Computers/Holder/TemplateButton,
			_on_computer_btn_pressed
		)
		
	for btn in $Modifiers/InfoButtons.get_children():
		btn.pressed.connect(_on_modifier_info_btn_pressed.bind(btn))
	
# General Helpers
func _create_btn(info, parent, template_btn, press_connection):
	var clone: Button = template_btn.duplicate(true)
	parent.add_child(clone)
	
	clone.name = info.display_name.to_lower()
	clone.text = info.display_name
	clone.visible = true
	clone.tooltip_text = info.description
	
	var resource_duplicate = info.duplicate(true)
	clone.set_meta("Resource", resource_duplicate)
	
	if info is ModifierBase:
		if info.icon:
			clone.icon = info.icon
		
		if info.modifier_locked:
			clone.text = ""
			
			var lower = ChallengeBase.ID.keys()[info.challenge_required_id].to_lower()
			var completed_challenges: Array = SaveManager.save_data.get("completed_challenges", [])
			
			if completed_challenges.is_empty():
				clone.get_node("Locked").visible = true
			else:
				if not lower in completed_challenges:
					clone.get_node("Locked").visible = true
		elif info.requires_purchase:	
			var lower = ModifierBase.ID.keys()[info.id].to_lower()
			
			if not lower in SaveManager.save_data.get("bought_modifiers"):
				clone.text = ""
				
				var purchase = clone.get_node("Purchase")
				var buy_btn = purchase.get_node("BuyButton")
				
				purchase.visible = true
				buy_btn.text = "%d Tokens" % info.purchase_cost
				
				buy_btn.pressed.connect(_on_buy_modifier_pressed.bind(clone))
		
	clone.pressed.connect(press_connection.bind(clone))

# Gamemode Helpers
func _update_paramters(gamemode: GamemodeBase):
	var template_step = $Gamemodes/Settings/Holder/TemplateStep
	var settings = gamemode.get_customisable_settings()
	
	for child in $Gamemodes/Settings/Holder.get_children():
		if child == template_step: continue
		child.queue_free()
	
	if settings.is_empty(): 
		$Gamemodes/Settings/NoPropertiesLabel.text = "[color=gold]%s [color=white]has no properties" % gamemode.display_name
		$Gamemodes/Settings/NoPropertiesLabel.visible = true
		return

	$Gamemodes/Settings/NoPropertiesLabel.visible = false

	for setting in settings:
		var config: Dictionary = settings[setting]
		var value = gamemode.get(setting)

		var clone = template_step.duplicate()
		$Gamemodes/Settings/Holder.add_child(clone)
		
		clone.name = setting.to_lower()
		clone.visible = true
		clone.setup(
			config.get("label"),
			float(value),
			config.get("min"),
			config.get("max"),
			config.get("step")	
		)
		
		clone.value_changed.connect(func(new_val):
			var is_integer = typeof(value) == TYPE_INT
			gamemode.set(setting, int(new_val) if is_integer else new_val)
		)

func _update_tasks(resource: GamemodeBase):	
	for label in $Gamemodes/Tasks/Holder.get_children():
		if label.name == "Template": continue
		label.queue_free()
		
	if resource.task_pool.is_empty():
		$Gamemodes/Tasks/NoPropertiesLabel.text = "[color=gold]%s [color=white]has no tasks" % resource.display_name
		$Gamemodes/Tasks/NoPropertiesLabel.visible = true
		return
	
	$Gamemodes/Tasks/NoPropertiesLabel.visible = false
	
	for task in resource.task_pool:
		var clone: RichTextLabel = $Gamemodes/Tasks/Holder/Template.duplicate(true)
		$Gamemodes/Tasks/Holder.add_child(clone)
		
		clone.name = task.display_name.to_lower()
		clone.text = "[color=gold]%s: [color=white]%s" % [task.display_name, task.description]
		clone.visible = true

# Modifier Helpers
func _update_info_btns():
	for btn: Button in info_buttons.get_children():
		var btn_position: int = btn.get_meta("Position")

		if (btn_position + 1) > selected_modifier_btns.size():
			btn.name = str(btn_position)
			btn.text = ""
			btn.disabled = true
			btn.get_node("NumberLabel").visible = false
			
			continue
			
		var modifier_btn = selected_modifier_btns[btn_position]
		var info: ModifierBase = modifier_btn.get_meta("Resource")
		
		btn.name = ModifierBase.ID.keys()[info.id].to_lower()
		btn.text = info.display_name
		btn.disabled = false
		
		btn.get_node("NumberLabel").visible = true
		btn.get_node("NumberLabel").text = "[%d]" % (btn_position + 1)
		btn.set_meta("ModifierBase", info)

# Button & Signal Connections
func _on_pick_gamemode_btn_pressed():
	var btn = $Gamemodes/PickGamemodeBtn
	
	if btn.get_meta("Open"):
		btn.set_meta("Open", false)
		gm_btn_holder.visible = false
		btn.text = "Pick Gamemode" if not selected_gamemode else selected_gamemode.display_name
		
		$Gamemodes/Description.visible = true
		$Gamemodes/Settings.visible = true
	else:
		btn.set_meta("Open", true)
		gm_btn_holder.visible = true
		btn.text = "CLOSE"
		
		$Gamemodes/Description.visible = false
		$Gamemodes/Settings.visible = false

func _on_gamemode_btn_pressed(btn: Button):
	var resource: GamemodeBase = btn.get_meta("Resource")
	selected_gamemode = resource
	
	$Gamemodes/Description.text = resource.description
	
	if selected_computer_btn and selected_gamemode:
		$StartButton.disabled = false
	else:
		$StartButton.disabled = true
	
	_on_pick_gamemode_btn_pressed()
	_update_paramters(resource)
	_update_tasks(resource)

func _on_modifier_btn_pressed(btn: Button):
	if selected_modifier_btns.has(btn):
		btn.text = btn.get_meta("Resource").display_name
		selected_modifier_btns.erase(btn)
		
		var old_selected = btn.get_node("SelectedLabel")
		if old_selected: old_selected.visible = false
	else:
		if selected_modifier_btns.size() == 5: return
		
		var selected = btn.get_node("SelectedLabel")
		if selected: selected.visible = true
		
		selected_modifier_btns.append(btn)
		
	_update_info_btns()

func _on_computer_btn_pressed(btn: Button):
	if selected_computer_btn:
		var old_selected = selected_computer_btn.get_node("SelectedLabel")
		if old_selected: old_selected.visible = false
		
	var selected = btn.get_node("SelectedLabel")
	if selected: selected.visible = true
	
	selected_computer_btn = btn
	
	if selected_computer_btn and selected_gamemode:
		$StartButton.disabled = false
	else:
		$StartButton.disabled = true
	
	var resource: ComputerBase = btn.get_meta("Resource")
	$Computers/Description.text = "[color=gold]%s: [color=white]%s" % [resource.display_name, resource.description]

func _on_return_btn_pressed() -> void:
	Signals.change_screen.emit("main_menu")

func _on_start_btn_pressed() -> void:
	var modifier_resources: Array[ModifierBase] = []
	
	for btn: Button in selected_modifier_btns:
		modifier_resources.append(btn.get_meta("Resource"))
	
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode_resource": selected_gamemode,
			"modifier_resource": modifier_resources,
			"computer_resource": selected_computer_btn.get_meta("Resource"),
		}
	)

# Modifier Buttons	
func _on_modifier_info_btn_pressed(btn: Button):
	var modifier_screen: Panel = $Overlay/Modifier
	
	modifier_screen.get_node("Title").text = btn.get_meta("ModifierBase").display_name
	modifier_screen.get_node("Description").text = btn.get_meta("ModifierBase").description
	
	_show_overlay(modifier_screen)
	
func _on_clear_selection_btn_pressed():
	for btn in selected_modifier_btns:
		btn.get_node("SelectedLabel").visible = false
	
	selected_modifier_btns.clear()
	
	_update_info_btns()
	
func _on_pick_random_btn_pressed():
	if selected_modifier_btns.size() == 5: return
		
	var modifier_btns = $Modifiers/ScrollContainer/Holder.get_children()
	
	for btn in modifier_btns:
		if btn.name == "TemplateButton": modifier_btns.erase(btn)
		if btn in selected_modifier_btns: modifier_btns.erase(btn)
	
	_on_modifier_btn_pressed(modifier_btns.pick_random())


func _on_close_overlay_pressed() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
	await tween.finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Overlay/CloseOverlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_buy_modifier_pressed(btn: Button) -> void:
	if PlayerManager.purchase_modifier(btn.get_meta("Resource")):
		btn.text = btn.get_meta("Resource").display_name
		var purchase = btn.get_node("Purchase")
		$Tokens.text = "Tokens: " + str(int(SaveManager.save_data.get("tokens")))
		
		var tween: Tween = create_tween()
		tween.tween_property(purchase, "position", purchase.position + Vector2(0, 100), 0.3)
		await tween.finished
		purchase.visible = false

func on_screen_change(_args):
	$Tokens.text = "Tokens: " + str(int(SaveManager.save_data.get("tokens")))
	
	for btn: Button in $Modifiers/ScrollContainer/Holder.get_children():
		if btn.name == "TemplateButton": continue
		
		var modifier: ModifierBase = btn.get_meta("Resource")
		
		if not modifier.modifier_locked: continue

		var lower = ChallengeBase.ID.keys()[modifier.challenge_required_id].to_lower()
		var completed_challenges: Array = SaveManager.save_data.get("completed_challenges", [])
		
		if lower in completed_challenges:
			btn.get_node("Locked").visible = false

func _show_overlay(screen: Panel):
	screen.visible = true
	
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
	await tween.finished
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	$Overlay/CloseOverlay.mouse_filter = Control.MOUSE_FILTER_STOP
