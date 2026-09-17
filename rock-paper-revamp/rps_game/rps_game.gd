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
var rt_stats: Dictionary = {}

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
	var player_move = rt_stats.get("player_move")
	var computer_move = rt_stats.get("computer_move")
	
	var outcome: String = ""
	
	if player_move == "":
		rt_stats["losses"] += 1
		rt_stats["computer_points"] += 1
		outcome = "loss"
	elif player_move == computer_move:
		rt_stats["draws"] += 1
		outcome = "draw"
	elif RULES.get(player_move) == computer_move:
		rt_stats["wins"] += 1
		rt_stats["player_points"] += 1
		outcome = "win"
	else:
		rt_stats["losses"] += 1
		rt_stats["computer_points"] += 1
		outcome = "loss"
	
	rt_stats["previous_outcome"].append(outcome)
	
	return outcome

func _determine_streak(outcome: String):
	if outcome == "draw":
		return
	
	if outcome == "loss":			
		rt_stats["current_streak"] = 0
	elif outcome == "win":
		rt_stats["current_streak"] += 1
		
	if rt_stats.get("current_streak") > rt_stats.get("best_streak"):
		rt_stats["best_streak"] = rt_stats["current_streak"]

func _toggle_move_btns(state: bool):
	for btn: Button in move_btns.get_children():
		btn.disabled = state
		
func _update_ui():
	$Scoreboard.text = "You: %d | AI: %d" % [
		rt_stats.get("player_points"),
		rt_stats.get("computer_points")
	]
	$Streak.text = "Streak: %d\nBest: %d" % [
		rt_stats.get("current_streak"),
		rt_stats.get("best_streak")
	]
	$RoundsPlayed.text = "Round: %d/%s" % [
		rt_stats.get("rounds_played"),
		"inf" if rt_stats.get("total_rounds") == -1 else str(rt_stats.get("total_rounds"))
	]
	
# Game Logic
func _start_game():
	rt_stats = $GamemodeHandler.setup_game(gamemode_resource)
	rt_stats = $ModifierHandler.apply_modifiers(rt_stats, modifier_resource)
	
	_update_ui()
	
	_start_round()
	
func _start_round():
	rt_stats["player_move"] = ""
	rt_stats["computer_move"] = ""
	
	$RoundEnd.visible = false
	continue_btn.visible = false
	
	_toggle_move_btns(false)
	
	round_timer.start(rt_stats.get("timer_length"))
	
func _end_round():
	round_timer.stop()
	_toggle_move_btns(true)
	
	rt_stats["computer_move"] = "paper"
	
	var player_move: String = rt_stats.get("player_move")
	
	var outcome = _determine_outcome()
	_determine_streak(outcome)
	
	$RoundEnd.visible = true
	$RoundEnd.text = "AI picked %s against your %s, %s" % [
		rt_stats.get("computer_move").capitalize(),
		player_move.capitalize(),
		"You won" if outcome == "win" else "You lost" if outcome == "loss" else "It's a draw"
	]
	
	rt_stats["rounds_played"] += 1
	rt_stats["player_history"].append(player_move)
	rt_stats["computer_history"].append(rt_stats.get("computer_move"))
	rt_stats["played_moves"][player_move] += 1
		
	_update_ui()
	
	game_over = $GamemodeHandler.check_round_end(rt_stats, gamemode_resource)
	
	if game_over:
		continue_btn.text = "End"
		
	continue_btn.visible = true
	
func _end_game():
	Signals.change_screen.emit("rps_selection")
	
# Button & Siganl Connections
func _on_move_btn_pressed(btn: Button):
	rt_stats["player_move"] = btn.name.to_lower()

func _on_continue_btn_pressed():
	if game_over:
		_end_game()
	else:
		_start_round()

func on_screen_change(information: Dictionary):
	gamemode_resource = information.get("gamemode_resource")
	modifier_resource = information.get("modifier_resource")
	
	_start_game()
