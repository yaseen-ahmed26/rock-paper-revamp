extends Control

#extends Control
#
#@onready var matches_description: RichTextLabel = $ColorRect/Matches/Description
#@onready var moves_description: RichTextLabel = $ColorRect/Moves/Description
#
#@onready var template_label: RichTextLabel = $Template
#
#func _ready() -> void:
	#_update_holders()
#
#func _update_holders():
	#var save_data = SaveManager.local_saved_data
	#
	#_populate_holder(
		#ContentManager.gamemodes.values(),
		#save_data.get("gamemodes"), 
		#$ColorRect/General/GamemodesHolder,
		#"[color=gold]GAMEMODES"
	#)
	#_populate_holder(
		#ContentManager.computers.values(),
		#save_data.get("opponents"), 
		#$ColorRect/General/OpponentsHolder,
		#"[color=gold]OPPONENTS"
	#)
	#
	#matches_description.text = "Points Won: %d\nPoints Lost: %d\nRounds Played: %d\nMatches Played: %d\n%d Wins, %d Losses, %d Draws" % [
		#save_data.get("points_won"),
		#save_data.get("points_lost"),
		#save_data.get("rounds_played"),
		#save_data.get("matches_played"),
		#save_data.get("total_wins"),
		#save_data.get("total_losses"),
		#save_data.get("total_draws"),
	#]
	#moves_description.text = "Played Rock: %d\nPlayed Scissors: %d\nPlayed Paper: %d" % [
		#save_data.get("played_rock"),
		#save_data.get("played_scissors"),
		#save_data.get("played_paper"),
	#]
	#
	#_populate_holder(
		#ContentManager.modifiers.values(),
		#save_data.get("modifiers"),
		#$ColorRect/Modifiers/ScrollContainer/Holder,
	#)
#
#func _populate_holder(array: Array, saved_values: Dictionary, holder: VBoxContainer, title: String = ""):	
	#for child in holder.get_children():
		#child.queue_free()
#
	#if not title.is_empty():
		#var clone: RichTextLabel = template_label.duplicate(true)
		#holder.add_child(clone)
		#
		#clone.name = title + "_title"
		#clone.text = title
		#clone.visible = true
		#
	#for i in array:
		#var clone: RichTextLabel = template_label.duplicate(true)
		#holder.add_child(clone)
		#
		#clone.name = str(i.id)
		#clone.text = i.display_name + ": " + str(int(saved_values.get(i.id, 0)))
		#clone.visible = true
#
#func on_screen_change(_details):	
	#_update_holders()
#
#func _on_return_button_pressed() -> void:
	#Signals.change_screen.emit("main_menu")
