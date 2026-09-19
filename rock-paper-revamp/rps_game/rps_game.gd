extends Control

@onready var modifier_timer: Timer = $ModifierTimer
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
var modifiers: Array[ModifierBase] = []

var game_stats: GameStats

var last_tracked_second: int = -1

var game_over: bool = false

# Godot Specific
func _ready() -> void:
	for btn in move_btns.get_children():
		btn.pressed.connect(_on_move_btn_pressed.bind(btn))
				
	round_timer.timeout.connect(_end_round)
	modifier_timer.timeout.connect(_on_modifier_timeout)

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

	if player_move == "":
		return GameStats.RoundOutcome.LOSS
	elif player_move == computer_move:
		return GameStats.RoundOutcome.DRAW
	elif RULES.get(player_move) == computer_move:
		return GameStats.RoundOutcome.WIN
	else:
		return GameStats.RoundOutcome.LOSS

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
	
	for btn: Button in move_btns.get_children():
		var stat: MoveStat = game_stats.btn_stats.get(btn.name.to_lower())
		
		btn.text = stat.display_text
		btn.visible = stat.visible
		btn.disabled = stat.lock
		
		btn.set_meta("Value", stat.actual_move)
	
# Game Logic
func _start_game():	
	game_stats = $GamemodeHandler.create_game_stats(gamemode_resource)
	$ModifierHandler.apply_initial_modifiers(game_stats, modifiers)
	
	_update_ui()
	
	_start_round()
	
func _start_round():
	game_stats.player_move = ""
	game_stats.computer_move = ""
	game_stats.outcome = GameStats.RoundOutcome.CLEARED
	game_stats.outcome_multiplier = 1
	game_stats.rounds_played += 1
	game_stats.reset_btn_state()
	
	$RoundEnd.visible = false
	continue_btn.visible = false
	
	_toggle_move_btns(false)
	
	$ModifierHandler.use_modifiers(game_stats, modifiers, ModifierBase.ApplyAt.ROUND_START)
	
	_update_ui()
	
	round_timer.start(game_stats.timer_length)
	modifier_timer.start(1.0)
	
func _end_round():
	round_timer.stop()
	modifier_timer.stop()
	_toggle_move_btns(true)
	
	game_stats.computer_move = "paper"
	var player_move: String = game_stats.player_move
	
	game_stats.outcome = _determine_outcome()
	
	$ModifierHandler.use_modifiers(game_stats, modifiers, ModifierBase.ApplyAt.ROUND_END)	
	
	game_stats.record_round_stats()
	game_stats.apply_round_outcome()
	
	$RoundEnd.visible = true
	$RoundEnd.text = "AI picked %s against your %s, %s" % [
		game_stats.computer_move.capitalize(),
		player_move.capitalize(),
		"You won" 
		if game_stats.outcome == GameStats.RoundOutcome.WIN
		else "You lost" 
		if game_stats.outcome == GameStats.RoundOutcome.LOSS
		else "It's a draw"
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
	print(btn.get_meta("Value"))
	game_stats.player_move = btn.get_meta("Value")

func _on_continue_btn_pressed():
	if game_over:
		_end_game()
	else:
		_start_round()

func on_screen_change(information: Dictionary):
	gamemode_resource = information.get("gamemode_resource")
	modifiers = information.get("modifier_resource")
	
	_start_game()

func _on_modifier_timeout():
	$ModifierHandler.use_modifiers(game_stats, modifiers, ModifierBase.ApplyAt.EVERY_SECOND)
	_update_ui()
