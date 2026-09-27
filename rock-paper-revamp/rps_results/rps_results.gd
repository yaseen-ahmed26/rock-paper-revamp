extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var match_meta_template := "Gamemode: [color=gold]%s [color=white]| Opponent: [color=gold]%s [color=white]| Modifiers: [color=gold]%d"
var played_moves_template := "And you also played [color=gold]Rock %d times[color=white], [color=gold]Paper %d times [color=white]and [color=gold]Scissors %d times[color=white]."
var points_template := "[You] %d • %d [AI]"
var rounds_played_template := "Played [color=gold]%d/%s [color=white]rounds with a [color=gold]%d [color=white]best win streak"
var points_breakdown := "[Wins] [color=gold]%d [color=white]| [Losses] [color=gold]%d [color=white]| [Draws] [color=gold]%d"

func on_screen_change(details: Dictionary):
	var stats: GameStats = details.get("stats")
	
	$MatchMeta.text = match_meta_template % [
		details.get("gamemode_name"),
		details.get("opponent_name"),
		details.get("modifier_count")
	]
	$PlayedMoves.text = played_moves_template % [
		stats.played_moves.get("rock"),
		stats.played_moves.get("paper"),
		stats.played_moves.get("scissors")
	]
	$Points/Label.text = points_template % [
		stats.player_points,
		stats.computer_points
	]
	$RoundsPlayed/Label.text = rounds_played_template % [
		stats.rounds_played,
		"inf" if stats.total_rounds == -1 else str(stats.total_rounds),
		stats.best_streak
	]
	$RoundBreakdown/Label.text = points_breakdown % [
		stats.wins,
		stats.losses,
		stats.draws
	]
	
	await get_tree().create_timer(1.5).timeout
	animation_player.play("show_results")
	
func _on_restart_btn_pressed():
	Signals.change_screen.emit("rps_game", {"restart": true})
	
func _on_return_btn_pressed():
	Signals.change_screen.emit("main_menu")
	
func _on_start_btn_pressed():
	Signals.change_screen.emit("rps_selection")
