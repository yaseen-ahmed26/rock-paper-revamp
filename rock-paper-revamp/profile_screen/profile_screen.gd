extends Control

@onready var template_label: RichTextLabel = $Template

func _ready() -> void:
	_update_holders()

func _update_holders():
	var save_data = SaveManager.local_saved_data
	
	_populate_holder(
		ContentManager.gamemodes.values(),
		save_data.get("gamemodes"), 
		$ColorRect/General/GamemodesHolder,
	)
	_populate_holder(
		ContentManager.computers.values(),
		save_data.get("opponents"), 
		$ColorRect/General/OpponentsHolder,
	)

	_populate_holder(
		ContentManager.modifiers.values(),
		save_data.get("modifiers"),
		$ColorRect/Modifiers/ScrollContainer/Holder,
	)
	
	$ColorRect/Matches/Wins/Label.text = "WINS\n%d" % save_data.get("total_wins")
	$ColorRect/Matches/Losses/Label.text = "LOSSES\n%d" % save_data.get("total_losses")
	$ColorRect/Matches/Draws/Label.text = "DRAWS\n%d" % save_data.get("total_draws")
	
	$ColorRect/Matches/Points.text = "POINTS\nWins %d • %d Lost" % [
		save_data.get("points_won"),
		save_data.get("points_lost")
	]
	
	$ColorRect/Matches/RoundsPlayed/Label.text = "Rounds Played: %d" % save_data.get("rounds_played")
	$ColorRect/Matches/MatchesPlayed/Label.text = "Matches Played: %d" % save_data.get("matches_played")
	
	$ColorRect/Moves/Rock/Label.text = "%d times" % save_data.get("played_rock")
	$ColorRect/Moves/Paper/Label.text = "%d times" % save_data.get("played_paper")
	$ColorRect/Moves/Scissors/Label.text = "%d times" % save_data.get("played_scissors")
	
func _populate_holder(array: Array, saved_values: Dictionary, holder: VBoxContainer):	
	for child in holder.get_children():
		child.queue_free()

	for i in array:
		var clone: RichTextLabel = template_label.duplicate(true)
		holder.add_child(clone)
		
		clone.name = str(i.id)
		clone.text = i.display_name
		clone.visible = true
		
		clone.get_node("Amount").text = str(int(saved_values.get(i.id, 0)))
		
		if i.icon:
			clone.get_node("Icon").texture = i.icon

func on_screen_change(_details):	
	_update_holders()

func _on_return_button_pressed() -> void:
	Signals.change_screen.emit("main_menu")
