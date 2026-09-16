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

var rt_stats: Dictionary = {
	"player_move": "",
	"ai_move": "",
	
	"player_points": 0,
	"ai_points": 0,
	
	"player_wins": 0,
	"player_losses": 0,
	"draws": 0,
	
	"current_streak": 0,
	"best_streak": 0
}

var last_tracked_second: int = -1

# Godot Specific
func _ready() -> void:
	_start_game()
	
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
	var computer_move = rt_stats.get("ai_move")
	
	if player_move == "":
		rt_stats["player_losses"] += 1
		rt_stats["ai_points"] += 1
		return "loss"
	elif player_move == computer_move:
		rt_stats["draws"] += 1
		return "draw"
	elif RULES.get(player_move) == computer_move:
		rt_stats["player_wins"] += 1
		rt_stats["player_points"] += 1
		return "win"
	else:
		rt_stats["player_losses"] += 1
		rt_stats["ai_points"] += 1
		return "loss"

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

# Game Logic
func _start_game():
	$Scoreboard.text = "You: %d | AI: %d" % [
		rt_stats.get("player_points"),
		rt_stats.get("ai_points")
	]
	
	_start_round()
	
func _start_round():
	rt_stats["player_move"] = ""
	rt_stats["ai_move"] = ""
	
	$RoundEnd.visible = false
	continue_btn.visible = false
	
	_toggle_move_btns(false)
	round_timer.start()
	
func _end_round():
	round_timer.stop()
	_toggle_move_btns(true)
	
	rt_stats["ai_move"] = "paper"
	
	var outcome = _determine_outcome()
	_determine_streak(outcome)
	
	$RoundEnd.visible = true
	$RoundEnd.text = "AI picked %s against your %s, %s" % [
		rt_stats.get("ai_move").capitalize(),
		rt_stats.get("player_move").capitalize(),
		"You won" if outcome == "win" else "You lost" if outcome == "loss" else "It's a draw"
	]
	$Scoreboard.text = "You: %d | AI: %d" % [
		rt_stats.get("player_points"),
		rt_stats.get("ai_points")
	]
	$Streak.text = "Streak: %d\nBest: %d" % [
		rt_stats.get("current_streak"),
		rt_stats.get("best_streak")
	]
	
	continue_btn.visible = true
	
func _end_game():
	pass
	
# Button & Siganl Connections
func _on_move_btn_pressed(btn: Button):
	rt_stats["player_move"] = btn.name.to_lower()

func _on_continue_btn_pressed():
	_start_round()
