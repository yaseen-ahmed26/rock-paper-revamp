extends Control

@export var challenge_pool: Array[ChallengeBase]

@onready var template_button: Button = $TemplateButton

var selected_challenge_btn: Button

func _ready() -> void:
	_create_challenge_btns()

# Helpers
func _create_challenge_btns():
	for challenge in challenge_pool:
		var clone: Button = template_button.duplicate(true)
		$ChallengeButtons.add_child(clone)
		
		clone.name = challenge.display_name.to_lower()
		clone.text = challenge.display_name
		clone.visible = true
		clone.tooltip_text = challenge.description
		
		var resource_duplicate = challenge.duplicate(true)
		clone.set_meta("Resource", resource_duplicate)
		
		clone.pressed.connect(_on_challenge_btn_pressed.bind(clone))

func _update_challenge_info(challenge: ChallengeBase):
	$ChallengeInfo/ChallengeName.text = challenge.display_name
	$ChallengeInfo/Description.text = challenge.description
	$ChallengeInfo/Modifiers.text = ", ".join(challenge.get_modifier_names())
	$ChallengeInfo/Gamemode.text = challenge.get_gamemode_name()
	
# Buttons & Signal Connections
func _on_start_btn_pressed():
	var challenge: ChallengeBase = selected_challenge_btn.get_meta("Resource")
	
	Signals.change_screen.emit(
		"rps_game",
		{
			"gamemode_resource": challenge.locked_gamemode,
			"modifier_resource": challenge.locked_modifiers,
		}
	)
	
func _on_return_btn_pressed():
	Signals.change_screen.emit("main_menu")

func _on_challenge_btn_pressed(btn: Button):
	if selected_challenge_btn:
		selected_challenge_btn.text = selected_challenge_btn.get_meta("Resource").display_name
	
	$StartButton.disabled = false
	
	btn.text = "[>] " + btn.text
	selected_challenge_btn = btn

	_update_challenge_info(btn.get_meta("Resource"))
