extends Control

@onready var round_timer: Timer = $RoundTimer
@onready var time_left: RichTextLabel = $TimeLeft
@onready var move_btns: HBoxContainer = $MoveButtons
@onready var continue_btn: Button = $ContinueButton
@onready var streak: RichTextLabel = $Streak

const MOVES: Array = ["rock", "paper", "scissors"]
const RULES: Dictionary = {
	"rock": "scissors",
	"paper": "rock",
	"scissors": "paper",
}

var gamemode_resource: GamemodeBase
var modifier_resource: ModifierBase

var game_stats: GameStats

var last_tracked_second: int = -1

var game_over: bool = false

# Godot Specific
func _ready() -> void:
	for btn in move_btns.get_children():
		btn.pressed.connect(_on_move_btn_pressed.bind(btn))
				
	round_timer.timeout.connect(_end_round)

func _process(_delta: float) -> void:
	if round_timer.is_stopped(): return
	
	var total_seconds: int = int(round_timer.time_left)
	var seconds = total_seconds % 60
	
	time_left.text = "00:%02d" % [seconds]
	
	var current_second: int = floor(round_timer.time_left) + 1
	
	if current_second < last_tracked_second:
		last_tracked_second = current_second

# Helpers
func _determine_outcome():
	var player_move = game_stats.player_move
	var computer_move = game_stats.computer_move
	
	var outcome: String = ""
	
	if player_move == "":
		outcome = "loss"
	elif player_move == computer_move:
		outcome = "draw"
	elif RULES.get(player_move) == computer_move:
		outcome = "win"
	else:
		outcome = "loss"
	
	return outcome

func _toggle_move_btns(state: bool):
	for btn: Button in move_btns.get_children():
		btn.disabled = state
		
func _update_ui():
	$Scoreboard.text = "You: %d | AI: %d" % [
		game_stats.player_points,
		game_stats.computer_points
	]
	$Streak.text = "Streak: %d\nBest: %d" % [
		game_stats.current_streak,
		game_stats.best_streak
	]
	$RoundsPlayed.text = "Round: %d/%s" % [
		game_stats.rounds_played,
		"inf" if game_stats.total_rounds == -1 else str(game_stats.total_rounds)
	]
	
# Game Logic
func _start_game():
	game_stats = $GamemodeHandler.create_game_stats(gamemode_resource)
	$ModifierHandler.apply_initial_modifiers(game_stats, modifier_resource)
	
	_update_ui()
	
	_start_round()
	
func _start_round():
	game_stats.player_move = ""
	game_stats.computer_move = ""
	
	$RoundEnd.visible = false
	continue_btn.visible = false
	
	_toggle_move_btns(false)
	
	round_timer.start(game_stats.timer_length)
	
func _end_round():
	round_timer.stop()
	_toggle_move_btns(true)
	
	game_stats.computer_move = "paper"
	
	var player_move: String = game_stats.player_move
	
	var outcome = _determine_outcome()
	game_stats.record_outcome(outcome)
	
	$RoundEnd.visible = true
	$RoundEnd.text = "AI picked %s against your %s, %s" % [
		game_stats.computer_move.capitalize(),
		player_move.capitalize(),
		"You won" if outcome == "win" else "You lost" if outcome == "loss" else "It's a draw"
	]
		
	_update_ui()
	
	game_over = $GamemodeHandler.check_round_end(game_stats, gamemode_resource)
	
	if game_over:
		continue_btn.text = "End"
		
	continue_btn.visible = true
	
func _end_game():
	Signals.change_screen.emit("rps_selection")
	
# Button & Siganl Connections
func _on_move_btn_pressed(btn: Button):
	game_stats.player_move = btn.name.to_lower()

func _on_continue_btn_pressed():
	if game_over:
		_end_game()
	else:
		_start_round()

func on_screen_change(information: Dictionary):
	gamemode_resource = information.get("gamemode_resource")
	modifier_resource = information.get("modifier_resource")
	
	_start_game()
