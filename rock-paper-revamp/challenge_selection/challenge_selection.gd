extends Control

@onready var template_button: Button = $Challenges/Holder/TemplateButton

var selected_challenge_btn: Button

func _ready() -> void:
	_create_challenge_btns()

# Helpers
func _create_challenge_btns():
	for challenge in ContentManager.challenges.values():
		var completed_challenges = SaveManager.local_saved_data.get("completed_challenges")
		
		var clone: Button = template_button.duplicate(true)
		$Challenges/Holder.add_child(clone)
		
		clone.name = challenge.display_name.to_lower()
		clone.text = challenge.display_name
		clone.visible = true
		clone.tooltip_text = challenge.description
		clone.set_meta("Completed", false)
		
		var resource_duplicate: ChallengeBase = challenge.duplicate(true)
		clone.set_meta("Resource", resource_duplicate)
		
		if resource_duplicate.id in completed_challenges:
			clone.get_node("Completed").visible = true
			clone.set_meta("Completed", true)
		
		clone.pressed.connect(_on_challenge_btn_pressed.bind(clone))

func _update_challenge_info(challenge: ChallengeBase, completed: bool):
	$ChallengeInfo/Title.text = challenge.display_name
	$ChallengeInfo/Description.text = challenge.description
	$ChallengeInfo/Modifiers.text = "[color=gold]Modifiers: \n[color=white]- " + "\n- ".join(challenge.get_modifier_names())
	$ChallengeInfo/Gamemode.text = "[color=gold]Gamemode: [color=white]" + challenge.get_gamemode_name()
	$ChallengeInfo/Computer.text = "[color=gold]Opponent: [color=white]" + challenge.get_opponent_name()
	
	if not completed:
		$ChallengeInfo/Reward.text = "[color=gold]Reward: [color=white]" + challenge.reward
	else:
		$ChallengeInfo/Reward.text = "[color=gold]Reward: [color=white]OBTAINED"

func _deselect_btn():
	$ChallengeInfo/Title.text = ""
	$ChallengeInfo/Description.text = ""
	$ChallengeInfo/Modifiers.text = ""
	$ChallengeInfo/Gamemode.text = ""
	$ChallengeInfo/Computer.text = ""
	$ChallengeInfo/Reward.text = ""
	
	if selected_challenge_btn:
		selected_challenge_btn.text = selected_challenge_btn.get_meta("Resource").display_name
		var old_selected = selected_challenge_btn.get_node("SelectedLabel")
		if old_selected: old_selected.visible = false
		
		selected_challenge_btn = null

# Buttons & Signal Connections
func _on_start_btn_pressed():
	var challenge: ChallengeBase = selected_challenge_btn.get_meta("Resource")
	
	var modifier_duplicate = challenge.locked_modifiers.duplicate_deep()
	modifier_duplicate.sort_custom(func(a, b): return a.group < b.group)
	
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode_resource": challenge.locked_gamemode,
			"modifier_resource": modifier_duplicate,
			"computer_resource": challenge.locked_computer,
			"challenge": challenge
		}
	)
	
	_deselect_btn()
	
func _on_return_btn_pressed():
	Signals.change_screen.emit("main_menu")
	_deselect_btn()

func _on_challenge_btn_pressed(btn: Button):
	if selected_challenge_btn:
		selected_challenge_btn.text = selected_challenge_btn.get_meta("Resource").display_name
		var old_selected = selected_challenge_btn.get_node("SelectedLabel")
		if old_selected: old_selected.visible = false
	
	$StartButton.disabled = false
	
	selected_challenge_btn = btn
	var selected = btn.get_node("SelectedLabel")
	if selected: selected.visible = true

	_update_challenge_info(btn.get_meta("Resource"), btn.get_meta("Completed"))

func on_screen_change(_args):
	var completed_challenges = SaveManager.local_saved_data.get("completed_challenges")
	for challenge in ContentManager.challenges.values():
		if challenge.id in completed_challenges:
			var btn = $Challenges/Holder.get_node(challenge.display_name.to_lower())
	
			btn.get_node("Completed").visible = true
			btn.set_meta("Completed", true)
