@tool
extends ConfirmationDialog

@onready var modifier_name: RichTextLabel = $VBoxContainer/ModifierName
@onready var description: RichTextLabel = $VBoxContainer/Description
@onready var purchase_needed: RichTextLabel = $VBoxContainer/PurchaseNeeded
@onready var challenge_required: RichTextLabel = $VBoxContainer/ChallengeRequired
@onready var number_of_rules: RichTextLabel = $VBoxContainer/NumberOfRules
@onready var has_internal: RichTextLabel = $VBoxContainer/HasInternal
@onready var exclude_badge: RichTextLabel = $VBoxContainer/ExcludeBadge
@onready var one_shot: RichTextLabel = $VBoxContainer/OneShot
@onready var tier: RichTextLabel = $VBoxContainer/Tier
@onready var stat_changes: RichTextLabel = $VBoxContainer/StatChanges

func _on_purchased_needed_checkbox_toggle(toggle: bool):
	var label = $VBoxContainer/PurchaseNeeded
	label.get_node("Cost").visible = toggle
	
func _on_challenge_required_checkbox_toggle(toggle: bool):
	var label = $VBoxContainer/ChallengeRequired
	label.get_node("ChallengeID").visible = toggle
	
func get_data() -> Dictionary:
	return {
		"name": modifier_name.get_node("LineEdit").text,
		"id": StringName(modifier_name.get_node("LineEdit").text.to_lower().replace(" ", "_")),
		"description": description.get_node("LineEdit").text,
		"purchase": {
			"required": purchase_needed.get_node("CheckBox").button_pressed,
			"cost": purchase_needed.get_node("Cost/SpinBox").value
		},
		"challenge": {
			"required": challenge_required.get_node("CheckBox").button_pressed,
			"id": StringName(challenge_required.get_node("ChallengeID/LineEdit").text)
		},
		"number_of_rules": number_of_rules.get_node("SpinBox").value,
		"has_internal": has_internal.get_node("CheckBox").button_pressed,
		"exclude_badge": exclude_badge.get_node("CheckBox").button_pressed,
		"one_shot": one_shot.get_node("CheckBox").button_pressed,
		"tier": tier.get_node("SpinBox").value,
		"stat_changes": stat_changes.get_node("SpinBox").value
	}
