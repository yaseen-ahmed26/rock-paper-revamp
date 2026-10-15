extends Panel

@onready var card: Panel = $Card
@onready var template_step: Panel = $"../Overlay/GamemodeSettings/Holder/TemplateStep"

const CARD_RIGHT_POSITION := Vector2(270, 52)
const CARD_LEFT_POSITION := Vector2(-145, 52)
const CARD_DEFAULT_POSITION := Vector2(79, 52)

const TWEEN_CYCLE_LENGTH: float = 0.3

var current_gamemode: GamemodeBase
var current_index: int = 0

func _ready() -> void:
	current_index = ContentManager.gamemodes.keys().find("endless")
	_update_card()

func _update_settings(gamemode: GamemodeBase):
	var settings = gamemode.get_customisable_settings()
	
	for child in $"../Overlay/GamemodeSettings/Holder".get_children():
		if child == template_step: continue
		child.queue_free()
	
	if settings.is_empty():
		$Card/SettingsButton.disabled = true
		return
	
	$Card/SettingsButton.disabled = false
	$"../Overlay/GamemodeSettings/Title".text = gamemode.display_name + " Settings"

	for setting in settings:
		var config: Dictionary = settings[setting]
		var value = gamemode.get(setting)

		var clone = template_step.duplicate()
		$"../Overlay/GamemodeSettings/Holder".add_child(clone)

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

func _update_tasks(gamemode: GamemodeBase):	
	for label in $"../Overlay/GamemodeTasks/Holder".get_children():
		if label.name == "Template": continue
		label.queue_free()
		
	if gamemode.task_pool.is_empty(): 
		$Card/TasksButton.disabled = true
		return
	
	$Card/TasksButton.disabled = false
	$"../Overlay/GamemodeTasks/Title".text = gamemode.display_name + " Tasks"
	
	for task in gamemode.task_pool:
		var clone: RichTextLabel = $"../Overlay/GamemodeTasks/Holder/Template".duplicate(true)
		$"../Overlay/GamemodeTasks/Holder".add_child(clone)
		
		clone.name = task.display_name.to_lower()
		clone.text = "[color=gold]%s: [color=white]%s" % [task.display_name, task.description]
		clone.visible = true

func _update_card():
	var gamemode: GamemodeBase = ContentManager.gamemodes.values().get(current_index)
	current_gamemode = gamemode

	$Card/Header/GamemodeName.text = "[ %s ]" % gamemode.display_name
	$Card/Description.text = gamemode.description
	
	if gamemode.icon:
		$Card/Header/Icon.texture = gamemode.icon
		$Card/Header/Icon.visible = true
	else:
		$Card/Header/Icon.visible = false
		
	_update_settings(gamemode)
	_update_tasks(gamemode)
	
func _cyle_card_previous():	
	var tween_left: Tween = create_tween()
	
	tween_left.set_parallel(true)
	tween_left.tween_property(card, "position", CARD_LEFT_POSITION, TWEEN_CYCLE_LENGTH)
	tween_left.tween_property(card, "modulate:a", 0.0, TWEEN_CYCLE_LENGTH)

	await tween_left.finished
	
	card.position = CARD_RIGHT_POSITION
	
	if current_index == 0:
		current_index = ContentManager.gamemodes.values().size() - 1
	else:
		current_index -= 1

	_update_card()
	
	var tween_right: Tween = create_tween()
	
	tween_right.set_parallel(true)
	tween_right.tween_property(card, "position", CARD_DEFAULT_POSITION, TWEEN_CYCLE_LENGTH)
	tween_right.tween_property(card, "modulate:a", 1.0, TWEEN_CYCLE_LENGTH)	
	
func _cyle_card_next():
	var tween_right: Tween = create_tween()
	
	tween_right.set_parallel(true)
	tween_right.tween_property(card, "position", CARD_RIGHT_POSITION, TWEEN_CYCLE_LENGTH)
	tween_right.tween_property(card, "modulate:a", 0.0, TWEEN_CYCLE_LENGTH)

	await tween_right.finished
	
	card.position = CARD_LEFT_POSITION
	
	if current_index >= (ContentManager.gamemodes.values().size() - 1):
		current_index = 0
	else:
		current_index += 1
		
	_update_card()
	
	var tween_left: Tween = create_tween()
	
	tween_left.set_parallel(true)
	tween_left.tween_property(card, "position", CARD_DEFAULT_POSITION, TWEEN_CYCLE_LENGTH)
	tween_left.tween_property(card, "modulate:a", 1.0, TWEEN_CYCLE_LENGTH)	

func _on_tasks_button_pressed() -> void:
	owner.show_overlay($"../Overlay/GamemodeTasks")

func _on_settings_button_pressed() -> void:
	owner.show_overlay($"../Overlay/GamemodeSettings")

func get_chosen_gamemode():
	return current_gamemode
