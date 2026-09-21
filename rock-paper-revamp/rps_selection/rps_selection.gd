extends Control

@export var gamemode_pool: Array[GamemodeBase]
@export var modifier_pool: Array[ModifierBase]

@onready var template_button: Button = $TemplateButton

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
	
	clone.set_meta("Resource", info)
	
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
			
# Button & Signal Connections
func _on_gamemode_btn_pressed(btn: Button):
	if selected_gamemode_btn:
		selected_gamemode_btn.text = selected_gamemode_btn.get_meta("Resource").display_name
	
	$StartButton.disabled = false
	
	btn.text = "[>] " + btn.text
	selected_gamemode_btn = btn
	
	_update_tasks()

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
