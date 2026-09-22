extends Control

@export var gamemode_pool: Array[GamemodeBase]
@export var modifier_pool: Array[ModifierBase]

@onready var template_button: Button = $TemplateButton
@onready var template_step: Panel = $GamemodeParameters/TemplateStep

var selected_gamemode_btn: Button
var selected_modifier_btns: Array[Button]

func _ready() -> void:
	for gamemode in gamemode_pool:
		create_btn(gamemode, $GamemodeButtons)
		
	for modifier in modifier_pool:
		create_btn(modifier, $ModifierButtons)

func _process(_delta: float) -> void:
	pass

# Helpers
func create_btn(info, parent):
	var clone: Button = template_button.duplicate(true)
	parent.add_child(clone)
	
	clone.name = info.display_name.to_lower()
	clone.text = info.display_name
	clone.visible = true
	clone.tooltip_text = info.description
	
	var resource_duplicate = info.duplicate(true)
	clone.set_meta("Resource", resource_duplicate)
	
	if parent == $GamemodeButtons:
		clone.pressed.connect(_on_gamemode_btn_pressed.bind(clone))
	else:
		clone.pressed.connect(_on_modifier_btn_pressed.bind(clone))

func _update_tasks():
	var resource: GamemodeBase = selected_gamemode_btn.get_meta("Resource")
	
	if resource:
		for btn in $TaskButtons.get_children():
			btn.queue_free()
		
		for task in resource.task_pool:
			var clone: Button = template_button.duplicate(true)
			$TaskButtons.add_child(clone)
			
			clone.name = task.display_name.to_lower()
			clone.text = "%s: %s" % [task.display_name, task.description]
			clone.visible = true
			clone.tooltip_text = task.description

func _update_paramters(gamemode: GamemodeBase):
	var settings = gamemode.get_customisable_settings()
	
	for child in $GamemodeParameters.get_children():
		if child == template_step: continue
		child.queue_free()
	
	if settings.is_empty(): return

	for setting in settings:
		var config: Dictionary = settings[setting]
		var value = gamemode.get(setting)

		var clone = template_step.duplicate()
		$GamemodeParameters.add_child(clone)
		
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
		selected_gamemode_btn.text = selected_gamemode_btn.get_meta("Resource").display_name
	
	$StartButton.disabled = false
	
	btn.text = "[>] " + btn.text
	selected_gamemode_btn = btn
	
	_update_tasks()
	_update_paramters(btn.get_meta("Resource"))

func _on_modifier_btn_pressed(btn: Button):
	if selected_modifier_btns.has(btn):
		btn.text = btn.get_meta("Resource").display_name
		selected_modifier_btns.erase(btn)
	else:
		if selected_modifier_btns.size() == 5: return
		
		btn.text = "[>] " + btn.text
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
		}
	)


func _on_return_btn_pressed() -> void:
	Signals.change_screen.emit("main_menu")
