extends Control

@export var challenge_pool: Array[ChallengeBase]
@onready var template_button: Button = $Challenges/Holder/TemplateButton


var selected_challenge_btn: Button

func _ready() -> void:
	_create_challenge_btns()

# Helpers
func _create_challenge_btns():
	print(SaveManager.save_data.get("completed_challenges"))
	for challenge in challenge_pool:
		var clone: Button = template_button.duplicate(true)
		$Challenges/Holder.add_child(clone)
		
		clone.name = challenge.display_name.to_lower()
		clone.text = challenge.display_name
		clone.visible = true
		clone.tooltip_text = challenge.description
		
		var resource_duplicate = challenge.duplicate(true)
		clone.set_meta("Resource", resource_duplicate)
		
		clone.pressed.connect(_on_challenge_btn_pressed.bind(clone))

func _update_challenge_info(challenge: ChallengeBase):
	$ChallengeInfo/Title.text = challenge.display_name
	$ChallengeInfo/Description.text = challenge.description
	$ChallengeInfo/Modifiers.text = "[color=gold]Modifiers: \n[color=white]- " + "\n- ".join(challenge.get_modifier_names())
	$ChallengeInfo/Gamemode.text = "[color=gold]Gamemode: [color=white]" + challenge.get_gamemode_name()
	$ChallengeInfo/Reward.text = "[color=gold]Reward: [color=white]" + challenge.reward
	$ChallengeInfo/Computer.text = "[color=gold]Opponent: [color=white]" + challenge.get_opponent_name()
	
# Buttons & Signal Connections
func _on_start_btn_pressed():
	var challenge: ChallengeBase = selected_challenge_btn.get_meta("Resource")
	
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode_resource": challenge.locked_gamemode,
			"modifier_resource": challenge.locked_modifiers,
			"computer_resource": challenge.locked_computer,
			"challenge": challenge
		}
	)
	
func _on_return_btn_pressed():
	Signals.change_screen.emit("main_menu")

func _on_challenge_btn_pressed(btn: Button):
	if selected_challenge_btn:
		selected_challenge_btn.text = selected_challenge_btn.get_meta("Resource").display_name
		var old_selected = selected_challenge_btn.get_node("SelectedLabel")
		if old_selected: old_selected.visible = false
	
	$StartButton.disabled = false
	
	selected_challenge_btn = btn
	var selected = btn.get_node("SelectedLabel")
	if selected: selected.visible = true

	_update_challenge_info(btn.get_meta("Resource"))
