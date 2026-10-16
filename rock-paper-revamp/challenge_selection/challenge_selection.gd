extends Control

@onready var card: Panel = $Challenge
@onready var carosuel_indicator: HBoxContainer = $CarosuelIndicator
@onready var modifier_template_button: Button = $Challenge/ModifierInfo/TemplateButton
@onready var overlay: ColorRect = $Overlay

const CARD_RIGHT_POSITION := Vector2(990, 243)
const CARD_LEFT_POSITION := Vector2(-315, 243)
const CARD_DEFAULT_POSITION := Vector2(337.5, 243)

const TWEEN_CYCLE_LENGTH: float = 0.3

var white: Color = Color("ffffff")
var blue: Color = Color("3364ff")

var current_challenge: ChallengeBase
var current_index: int = 0

var indicator_dots: Array[Control] = []

func _ready() -> void:
	_create_carosuel()
	_update_card()
	_update_carosuel()

func _create_carosuel():
	var template: Panel = $CarosuelIndicator/Template
	
	for dot in indicator_dots:
		dot.queue_free()

	indicator_dots.clear()
	
	for i in range(ContentManager.challenges.size()):
		var clone: Panel = template.duplicate()
		$CarosuelIndicator.add_child(clone)
		clone.visible = true
		indicator_dots.append(clone)

func _update_carosuel():
	for i in range(indicator_dots.size()):
		var dot = indicator_dots[i]
		dot.self_modulate = blue if i == current_index else white

func _update_card():
	var challenge: ChallengeBase = ContentManager.challenges.values().get(current_index)
	current_challenge = challenge
	
	if challenge.icon:
		$Challenge/ChallengeIcon.texture = challenge.icon

	$Challenge/ChallengeName.text = challenge.display_name.to_upper()
	$Challenge/ChallengeDescription.text = challenge.description
	$Challenge/GamemodeName/Label.text = challenge.locked_gamemode.display_name
	$Challenge/GamemodeDescription/Label.text = challenge.locked_gamemode.description
	$Challenge/OpponentName/Label.text = challenge.locked_computer.display_name
	$Challenge/OpponentDescription/Label.text = challenge.locked_computer.description
	$Challenge/RewardLabel.text = challenge.reward
	
	for child in $Challenge/ModifierInfo.get_children():
		if child == modifier_template_button: continue
		child.queue_free()
		
	for modifier in challenge.locked_modifiers:
		var clone: Button = modifier_template_button.duplicate(true)
		var info_rect = clone.get_node("Info")
		
		$Challenge/ModifierInfo.add_child(clone)
		
		clone.visible = true
		
		info_rect.get_node("ModifierName").text = modifier.display_name
		info_rect.get_node("Icon").texture = modifier.icon
	
	
	
func _on_return_button_pressed() -> void:
	Signals.change_screen.emit("main_menu")

func _on_start_button_pressed() -> void:	
	var modifier_duplicate = current_challenge.locked_modifiers.duplicate_deep()
	modifier_duplicate.sort_custom(func(a, b): return a.group < b.group)
	
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode_resource": current_challenge.locked_gamemode,
			"modifier_resource": modifier_duplicate,
			"computer_resource": current_challenge.locked_computer,
			"challenge": current_challenge
		}
	)

func _on_next_pressed() -> void:
	var tween_right: Tween = create_tween()
	
	tween_right.set_parallel(true)
	tween_right.tween_property(card, "position", CARD_RIGHT_POSITION, TWEEN_CYCLE_LENGTH)
	tween_right.tween_property(card, "modulate:a", 0.0, TWEEN_CYCLE_LENGTH)

	await tween_right.finished
	
	card.position = CARD_LEFT_POSITION
	
	if current_index >= (ContentManager.challenges.values().size() - 1):
		current_index = 0
	else:
		current_index += 1
		
	_update_card()
	_update_carosuel()
	
	var tween_left: Tween = create_tween()
	
	tween_left.set_parallel(true)
	tween_left.tween_property(card, "position", CARD_DEFAULT_POSITION, TWEEN_CYCLE_LENGTH)
	tween_left.tween_property(card, "modulate:a", 1.0, TWEEN_CYCLE_LENGTH)	

func _on_previous_pressed() -> void:
	var tween_left: Tween = create_tween()
	
	tween_left.set_parallel(true)
	tween_left.tween_property(card, "position", CARD_LEFT_POSITION, TWEEN_CYCLE_LENGTH)
	tween_left.tween_property(card, "modulate:a", 0.0, TWEEN_CYCLE_LENGTH)

	await tween_left.finished
	
	card.position = CARD_RIGHT_POSITION
	
	if current_index == 0:
		current_index = ContentManager.challenges.values().size() - 1
	else:
		current_index -= 1

	_update_card()
	_update_carosuel()
	
	var tween_right: Tween = create_tween()
	
	tween_right.set_parallel(true)
	tween_right.tween_property(card, "position", CARD_DEFAULT_POSITION, TWEEN_CYCLE_LENGTH)
	tween_right.tween_property(card, "modulate:a", 1.0, TWEEN_CYCLE_LENGTH)	
