extends Control

@onready var round_timer: Timer = $RoundTimer
@onready var modifier_timer: Timer = $ModifierTimer
@onready var timer_label: RichTextLabel = $Timer/Label
@onready var move_btns: VBoxContainer = $MoveButtons
@onready var action_button: Button = $ActionButton

@onready var ai_animation: AnimationPlayer = $AIAnimation
@onready var player_animation: AnimationPlayer = $PlayerAnimation

const RULES: Dictionary = {
	"rock": "scissors",
	"paper": "rock",
	"scissors": "paper",
}

var gamemode: GamemodeBase
var computer: ComputerBase
var modifiers: Array[ModifierBase] = []
var challenge: ChallengeBase
var tasks_completed = 0

var game_stats: GameStats

var game_over: bool = false
var game_paused: bool = false

var card_icons: Dictionary[String, Texture] = {
	"rock": preload("res://assets/icons/rps_game/rock.png"),
	"paper": preload("res://assets/icons/rps_game/paper.png"),
	"scissors": preload("res://assets/icons/rps_game/scissors.png")
}

# Godot Specific
func _ready() -> void:
	for btn in move_btns.get_children():
		btn.pressed.connect(_on_move_btn_pressed.bind(btn))
				
	round_timer.timeout.connect(_end_round)
	modifier_timer.timeout.connect(_on_modifier_timeout)

func _process(_delta: float) -> void:
	if round_timer.is_stopped(): return
	if game_paused: return
	
	var seconds: int = int(round_timer.time_left) % 60	
	timer_label.text = "[color=%s]%02d" % ["white" if seconds > 3 else "red", seconds]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				var btn = move_btns.get_node("rock")
				_on_move_btn_pressed(btn)
			KEY_2:
				var btn = move_btns.get_node("paper")
				_on_move_btn_pressed(btn)
			KEY_3:
				var btn = move_btns.get_node("scissors")
				_on_move_btn_pressed(btn)
			KEY_ESCAPE:
				_toggle_overlay()
			KEY_ENTER:
				_on_action_btn_pressed()

# General helpers
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

func _check_completed_tasks():
	if gamemode.task_pool.is_empty(): return
	
	for task in gamemode.task_pool:
		if task.timing != TaskBase.Timing.ROUND_END: continue
		
		var complete = task.check_completion(game_stats)
	
		if complete:
			tasks_completed += 1

# UI Helpers
func _update_game_ui():
	$PlayerScore.text = "You [color=gold][%s]" % [
		str(("%.1f" % game_stats.player_points).trim_suffix(".0"))
	]
	$AIScore.text = "[color=gold][%s] [color=white]%s" % [
		str(("%.1f" % game_stats.computer_points).trim_suffix(".0")),
		computer.display_name
	]
	$Streak.text = "[%d] Streak\n[%d] Best" % [
		game_stats.current_streak,
		game_stats.best_streak
	]
	$RoundsPlayed.text = "Round %d/%s" % [
		game_stats.rounds_played,
		"inf" if game_stats.total_rounds == -1 else str(game_stats.total_rounds)
	]
	
	for btn: Button in move_btns.get_children():
		var stat: MoveStat = game_stats.btn_stats.get(btn.name.to_lower())
		
		btn.name = stat.actual_move
		# btn.text = stat.display_text
		btn.visible = stat.visible
		btn.disabled = stat.lock
				
		if stat.lock:
			btn.get_node("Keybind").visible = false
		else:
			btn.get_node("Keybind").visible = true
		
		btn.set_meta("Value", stat.actual_move)
	
func _set_overlay_info():
	var modifier_names: Array = []
	
	for modifier in modifiers: 
		modifier_names.append(modifier.display_name)
	
	$Overlay/MatchInfo.text = "Max Points: %s\nMax Rounds: %s\nModifiers Active:\n%s" % [
		"Infinite" if game_stats.max_points == -1 else str(game_stats.max_points),
		"Infinite" if game_stats.total_rounds == -1 else str(game_stats.total_rounds),
		", ".join(modifier_names) if not modifier_names.is_empty() else "None"
	]
	$Overlay/GamemodeInfo.text = "[color=gold]%s: [color=white]%s" % [
		gamemode.display_name,
		gamemode.description
	]
	var lines: Array[String] = ["Tasks:"]

	for task in gamemode.task_pool:
		lines.append("[color=gold]%s: [color=white]%s" % [task.display_name, task.description])
	
	if lines.is_empty():
		$Overlay/Tasks.text = "No Tasks"
	else:
		$Overlay/Tasks.text = "\n".join(lines)
	
func _toggle_move_btns(state: bool):
	for btn in move_btns.get_children():
		btn.disabled = state
		
		if state:
			btn.get_node("Keybind").visible = false
		else:
			btn.get_node("Keybind").visible = true

func _update_action_btn(mode: String):
	action_button.set_meta("Mode", mode)
	
	match mode:
		"RoundEnd":
			action_button.text = "End Round"
		"GameOver":
			action_button.text = "End Game"
		"NextRound":
			action_button.text = "Next Round"
	
func _flip_cards():
	$PlayerCard/FrontDesign.texture = card_icons.get(game_stats.player_move)
	$AICard/FrontDesign.texture = card_icons.get(game_stats.computer_move)
	
	player_animation.play("flip_card")
	await get_tree().create_timer(0.2).timeout
	ai_animation.play("flip_card")
	
func _reset_cards():
	player_animation.play("unflip_card")
	ai_animation.play("unflip_card")
	
# Overlay
func _toggle_overlay():
	var tween: Tween = create_tween()
	var overlay: ColorRect = $Overlay
	
	if game_paused:
		tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
		overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	game_paused = not game_paused

	round_timer.paused = game_paused
	modifier_timer.paused = game_paused

# Logic
func _hard_reset_game():
	_soft_reset_game()
	
	gamemode = null
	computer = null
	modifiers = []
	challenge = null
	
func _soft_reset_game():
	player_animation.play("RESET")
	ai_animation.play("RESET")
	tasks_completed = 0
	
func _start_game():
	game_stats = GameStats.new()
	
	for modifier in modifiers:		
		modifier.setup()
		
		if modifier.starting_stat_changes.is_empty(): continue
		
		for change: StatChange in modifier.starting_stat_changes:
			game_stats.apply_stat_change(change)
	
	gamemode.apply_stats_edit(game_stats)
		
	_update_game_ui()
	_set_overlay_info()
	_start_round()
	
func _start_round():
	if not game_stats.player_move.is_empty():
		var old_btn: Button = move_btns.get_node(game_stats.player_move)	
		old_btn.get_node("SelectedLabel").visible = false
	
	game_stats.reset_round()
	
	$RoundEnd.visible = false

	_update_action_btn("RoundEnd")	
	_toggle_move_btns(false)
	
	for modifier in modifiers:
		if modifier.applied: continue
		modifier.check_rules_and_apply(game_stats, ModifierBase.ApplyAt.ROUND_START)
	
	_update_game_ui()
	_reset_cards()
	
	round_timer.start(game_stats.timer_length)
	modifier_timer.start(1.0)
	
func _end_round():
	round_timer.stop()
	modifier_timer.stop()
	
	game_stats.computer_move = computer.pick_move(game_stats)
	var player_move: String = game_stats.player_move
	
	game_stats.outcome = _determine_outcome()
	
	for modifier in modifiers:
		if modifier.applied: continue
		modifier.check_rules_and_apply(game_stats, ModifierBase.ApplyAt.ROUND_END)
	
	game_stats.record_round_stats()
	game_stats.apply_round_outcome()
	
	_flip_cards()
		
	$RoundEnd.visible = true
		
	if game_stats.outcome == GameStats.RoundOutcome.WIN:
		$RoundEnd.text = "You won the round! +%d points to you" % game_stats.get_points_on_win()
	elif game_stats.outcome == GameStats.RoundOutcome.LOSS:
		$RoundEnd.text = "You lost the round, +%d points to opponent" % game_stats.get_points_on_loss()
	elif game_stats.outcome == GameStats.RoundOutcome.DRAW:
		$RoundEnd.text = "Round draw, No points awarded"
	elif game_stats.outcome == GameStats.RoundOutcome.DISCARD:
		$RoundEnd.text = "Round has been discarded, No points awarded"
				
	_update_game_ui()
	_check_completed_tasks()
		
	game_over = gamemode.is_game_over(game_stats)
		
	if game_over:
		_update_action_btn("GameOver")
	else:
		_update_action_btn("NextRound")
	
	_toggle_move_btns(true)
	
func _end_game():
	_check_completed_tasks()
	
	SaveManager.record_match(game_stats, gamemode, computer, modifiers, tasks_completed, challenge)
	
	Signals.change_screen.emit("rps_results", {
		"stats": game_stats,
		"gamemode_name": gamemode.display_name,
		"opponent_name": computer.display_name,
		"modifier_count": modifiers.size()
	})
	
func _restart_game():
	_soft_reset_game()
	_start_game()

# Button Connections
# Move
func _on_move_btn_pressed(btn: Button):	
	if not game_stats.player_move.is_empty():
		var old_btn: Button = move_btns.get_node(game_stats.player_move)
		old_btn.get_node("SelectedLabel").visible = false
	
	game_stats.player_move = btn.get_meta("Value")

	btn.get_node("SelectedLabel").visible = true


func _on_restart_btn_pressed():
	_restart_game()
	
func _on_quit_btn_pressed():
	_end_game()
	
func _on_action_btn_pressed():
	var mode: String = action_button.get_meta("Mode")
	
	if mode == "RoundEnd":
		_end_round()
	elif mode == "GameOver":
		_end_game()
	elif mode == "NextRound":
		_start_round()

# Signal & Timer Connections
func _on_modifier_timeout():
	for modifier in modifiers:
		if modifier.applied: continue
		modifier.check_rules_and_apply(game_stats, ModifierBase.ApplyAt.EVERY_SECOND)
		
	_update_game_ui()

func on_screen_change(information: Dictionary):
	if information.get("restart"): 
		_restart_game() 
		return
		
	_hard_reset_game()
	
	gamemode = information.get("gamemode_resource")
	modifiers = information.get("modifier_resource")
	computer = information.get("computer_resource")
	challenge = information.get("challenge", null)
	
	_start_game()
