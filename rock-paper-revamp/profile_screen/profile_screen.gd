extends Control

@onready var matches_description: RichTextLabel = $ColorRect/Matches/Description
@onready var moves_description: RichTextLabel = $ColorRect/Moves/Description
@onready var general_description: RichTextLabel = $ColorRect/General/Description
@onready var modifiers_description: RichTextLabel = $ColorRect/Modifiers/Description

func on_screen_change(_details):
	var save_data = SaveManager.save_data

	matches_description.text = "Points Won: %d\nPoints Lost: %d\nRounds Played: %d\nMatches Played: %d\n%d Wins, %d Losses, %d Draws" % [
		save_data.get("points_won"),
		save_data.get("points_lost"),
		save_data.get("rounds_played"),
		save_data.get("matches_played"),
		save_data.get("total_wins"),
		save_data.get("total_losses"),
		save_data.get("total_draws"),
	]
	moves_description.text = "Played Rock: %d\nPlayed Scissors: %d\nPlayed Paper: %d" % [
		save_data.get("played_rock"),
		save_data.get("played_scissors"),
		save_data.get("played_paper"),
	]
	
	for k in save_data.get("modifiers").keys():
		var v = save_data.get("modifiers")[k]
		modifiers_description.text = modifiers_description.text + "%s: %d\n" % [
			k.capitalize(),
			v
		]
	
	general_description.text = "First to: %d\nBest Of: %d\nComeback: %d\nSurvival: %d\nEndless: %d\n\nThe Gambler: %d\nStatistics Guy: %d" % [
		save_data.get("gamemodes")["first_to"],
		save_data.get("gamemodes")["best_of"],
		save_data.get("gamemodes")["comeback"],
		save_data.get("gamemodes")["survival"],
		save_data.get("gamemodes")["endless"],
		save_data.get("opponents")["the_gambler"],
		save_data.get("opponents")["statistics_guy"],
	]


func _on_return_button_pressed() -> void:
	Signals.change_screen.emit("main_menu")
