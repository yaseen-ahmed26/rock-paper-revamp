extends Control

@export var gamemode_pool: Array[GamemodeBase]
@export var modifier_pool: Array[ModifierBase]
@export var computer_pool: Array[ComputerBase]

@onready var gm_btn_holder: VBoxContainer = $Gamemodes/PickGamemodeBtn/BtnHolder

var selected_gamemode: GamemodeBase

var selected_modifier_btns: Array[Button] = []
var selected_computer_btn: Button

# Godot
func _ready() -> void:
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
			$Modifiers/Holder,
			$Modifiers/Holder/TemplateButton,
			_on_modifier_btn_pressed
		)
		
	for computer in computer_pool:
		_create_btn(
			computer,
			$Computers/Holder,
			$Computers/Holder/TemplateButton,
			_on_computer_btn_pressed
		)
	
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

"""
@onready var gm_template_button: Button = $GamemodeTemplateButton
@onready var template_step: Panel = $GamemodeSettings/Holder/TemplateStep
@onready var md_template_button: Button = $ModifierTemplateButton
@onready var ct_template_button: Button = $ComputerTemplateButton

var selected_gamemode_btn: Button
var selected_modifier_btns: Array[Button]
var selected_computer_btn: Button

func _ready() -> void:
	for gamemode in gamemode_pool:
		create_btn(gamemode, $Gamemodes/Holder, gm_template_button)
		
	for modifier in modifier_pool:
		create_btn(modifier, $Modifiers/Holder, md_template_button)
		
	for computer in computer_pool:
		create_btn(computer, $Computers/Holder, ct_template_button)

func _process(_delta: float) -> void:
	pass

# Helpers
func create_btn(info, parent, template: Button):
	var clone: Button = template.duplicate(true)
	parent.add_child(clone)
	
	clone.name = info.display_name.to_lower()
	clone.text = info.display_name
	clone.visible = true
	clone.tooltip_text = info.description
	
	var resource_duplicate = info.duplicate(true)
	clone.set_meta("Resource", resource_duplicate)
	
	if parent == $Gamemodes/Holder:
		clone.pressed.connect(_on_gamemode_btn_pressed.bind(clone))
	elif parent == $Modifiers/Holder:
		clone.pressed.connect(_on_modifier_btn_pressed.bind(clone))
	elif parent == $Computers/Holder:
		clone.pressed.connect(_on_computer_btn_pressed.bind(clone))

func _update_tasks():
	var resource: GamemodeBase = selected_gamemode_btn.get_meta("Resource")
	
	if resource:
		for label in $GamemodeTasks/Holder.get_children():
			if label.name == "Template": continue
			label.queue_free()
			
		if resource.task_pool.is_empty():
			$GamemodeTasks/NoPropertiesLabel.text = "[color=gold]%s [color=white]has no tasks" % resource.display_name
			$GamemodeTasks/NoPropertiesLabel.visible = true
			return
		
		$GamemodeTasks/NoPropertiesLabel.visible = false
		
		for task in resource.task_pool:
			var clone: RichTextLabel = $GamemodeTasks/Holder/Template.duplicate(true)
			$GamemodeTasks/Holder.add_child(clone)
			
			clone.name = task.display_name.to_lower()
			clone.text = "%s: %s" % [task.display_name, task.description]
			clone.visible = true
			clone.tooltip_text = task.description

func _update_paramters(gamemode: GamemodeBase):
	var settings = gamemode.get_customisable_settings()
	
	for child in $GamemodeSettings/Holder.get_children():
		if child == template_step: continue
		child.queue_free()
	
	if settings.is_empty(): 
		$GamemodeSettings/NoPropertiesLabel.text = "[color=gold]%s [color=white]has no properties to edit" % gamemode.display_name
		$GamemodeSettings/NoPropertiesLabel.visible = true
		return

	$GamemodeSettings/NoPropertiesLabel.visible = false

	for setting in settings:
		var config: Dictionary = settings[setting]
		var value = gamemode.get(setting)

		var clone = template_step.duplicate()
		$GamemodeSettings/Holder.add_child(clone)
		
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

# Button & Signal Connections
func _on_gamemode_btn_pressed(btn: Button):
	if selected_gamemode_btn:
		var old_selected = selected_gamemode_btn.get_node("SelectedLabel")
		if old_selected: old_selected.visible = false
		
		selected_gamemode_btn.text = selected_gamemode_btn.get_meta("Resource").display_name
	
	selected_gamemode_btn = btn
	
	if selected_computer_btn and selected_gamemode_btn:
		$StartButton.disabled = false
	else:
		$StartButton.disabled = true
	
	var selected = btn.get_node("SelectedLabel")
	if selected: selected.visible = true
	
	var resource: GamemodeBase = btn.get_meta("Resource")
	$Gamemodes/Description.text = "[color=gold]%s: [color=white]%s" % [resource.display_name, resource.description]
	
	_update_tasks()
	_update_paramters(btn.get_meta("Resource"))

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

func _on_start_btn_pressed() -> void:
	var modifier_resources: Array[ModifierBase] = []
	
	for btn: Button in selected_modifier_btns:
		modifier_resources.append(btn.get_meta("Resource"))
	
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode_resource": selected_gamemode_btn.get_meta("Resource"),
			"modifier_resource": modifier_resources,
			"computer_resource": selected_computer_btn.get_meta("Resource"),
		}
	)

func _on_computer_btn_pressed(btn: Button):
	if selected_computer_btn:
		var old_selected = selected_computer_btn.get_node("SelectedLabel")
		if old_selected: old_selected.visible = false
		
	var selected = btn.get_node("SelectedLabel")
	if selected: selected.visible = true
	
	selected_computer_btn = btn
	
	if selected_computer_btn and selected_gamemode_btn:
		$StartButton.disabled = false
	else:
		$StartButton.disabled = true
	
	var resource: ComputerBase = btn.get_meta("Resource")
	$Computers/Description.text = "[color=gold]%s: [color=white]%s" % [resource.display_name, resource.description]
	
func _on_return_btn_pressed() -> void:
	Signals.change_screen.emit("main_menu")
"""
