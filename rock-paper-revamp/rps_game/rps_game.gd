extends Control

@onready var modifier_timer: Timer = $ModifierTimer
@onready var round_timer: Timer = $RoundTimer
@onready var time_left: RichTextLabel = $TimeLeft
@onready var move_btns: HBoxContainer = $MoveButtons
@onready var streak: RichTextLabel = $Streak
@onready var modifiers_active: VBoxContainer = $ModifiersActive

const RULES: Dictionary = {
	"rock": "scissors",
	"paper": "rock",
	"scissors": "paper",
}

var gamemode: GamemodeBase
var computer: ComputerBase
var modifiers: Array[ModifierBase] = []

var game_stats: GameStats

var game_over: bool = false
var game_paused: bool = false

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
	time_left.text = "00:%02d" % [seconds]

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
				_show_overlay()

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
		
		if state:
			btn.get_node("Keybind").visible = false
		else:
			btn.get_node("Keybind").visible = true
		
func _update_ui():
	$Scoreboard.text = "[You] %d • %d [AI]" % [
		game_stats.player_points,
		game_stats.computer_points
	]
	$Streak.text = "[%d] Streak\n[%d] Best" % [
		game_stats.current_streak,
		game_stats.best_streak
	]
	$RoundsPlayed.text = "Round [%d/%s]" % [
		game_stats.rounds_played,
		"inf" if game_stats.total_rounds == -1 else str(game_stats.total_rounds)
	]
	
	for btn: Button in move_btns.get_children():
		var stat: MoveStat = game_stats.btn_stats.get(btn.name.to_lower())
		
		btn.name = stat.actual_move
		btn.text = stat.display_text
		btn.visible = stat.visible
		btn.disabled = stat.lock
		
		if stat.lock:
			btn.get_node("Keybind").visible = false
		else:
			btn.get_node("Keybind").visible = true
		
		btn.set_meta("Value", stat.actual_move)

# Overlay Logic
func _show_overlay():
	var tween: Tween = create_tween()
	var overlay: ColorRect = $Overlay
	
	if game_paused:
		tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
		overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	game_paused = not game_paused

	$RoundTimer.paused = game_paused
	$ModifierTimer.paused = game_paused

func _set_overlay_info():
	var modifier_names: Array = []
	for m in modifiers: 
		modifier_names.append(m.display_name)
	
	$Overlay/MatchInfo.text = "Max Points: %s\nMax Rounds: %s\nModifiers Active:\n[%s]" % [
		"Infinite" if game_stats.max_points == -1 else str(game_stats.max_points),
		"Infinite" if game_stats.total_rounds == -1 else str(game_stats.total_rounds),
		", ".join(modifier_names)
	]
	$Overlay/GamemodeInfo.text = "[color=gold]%s: [color=white]%s" % [
		gamemode.display_name,
		gamemode.description
	]
	$Overlay/Tasks.text = "Tasks:\n"
	for t in gamemode.task_pool:
		$Overlay/Tasks.text = $Overlay/Tasks.text + "[color=gold]%s: [color=white]%s\n" % [
			t.display_name,
			t.description
		]

# Modifier Helpers
func _animate_used_modifiers() -> void:
	for mod_id in game_stats.round_activated_modifiers:
		var current_modifier: ModifierBase
		
		for modifier in modifiers:
			if modifier.id == mod_id:
				current_modifier = modifier
		
		if not current_modifier: continue
		if current_modifier.exclude_badge: continue
		
		var lower_id: String = ModifierBase.ID.keys()[mod_id].to_lower()
		var label = modifiers_active.get_node(lower_id)
		
		_flash_label(label)

func _flash_label(label: RichTextLabel) -> void:
	label.visible = true
	label.modulate = Color.GREEN
	
	await get_tree().create_timer(0.5).timeout
	label.modulate = Color.WHITE

	await get_tree().create_timer(0.5).timeout
	label.modulate = Color.GREEN
	
	await get_tree().create_timer(0.5).timeout
	label.modulate = Color.WHITE
	
	await get_tree().create_timer(0.5).timeout
	label.modulate = Color.GREEN

	await get_tree().create_timer(0.5).timeout
	label.visible = false

# Game Logic
func _restart_game():
	game_over = false
	game_paused = false
	_start_game()

func _start_game():
	for modifier in modifiers:
		var clone = $ModifiersActive/Template.duplicate()
		var lower_id: String = ModifierBase.ID.keys()[modifier.id].to_lower()
		$ModifiersActive.add_child(clone)
	
		clone.text = modifier.display_name
		clone.visible = false
		clone.name = lower_id
	
	game_stats = GameStats.new()
	
	gamemode.apply_stats_edit(game_stats)
	$ModifierHandler.apply_initial_modifiers(game_stats, modifiers)
	
	_update_ui()
	_set_overlay_info()
	_start_round()
	
func _start_round():
	if not game_stats.player_move.is_empty():
		var old_btn: Button = move_btns.get_node(game_stats.player_move)	
		old_btn.get_node("SelectedLabel").visible = false
	
	game_stats.reset_round()
	
	$MovesPicked.visible = false
	$RoundEnd.visible = false

	$ActionButton.text = "End Round"
	$ActionButton.set_meta("Mode", "RoundEnd")
	
	_toggle_move_btns(false)
	
	$ModifierHandler.use_modifiers(game_stats, modifiers, ModifierBase.ApplyAt.ROUND_START)
	
	_update_ui()
	
	round_timer.start(game_stats.timer_length)
	modifier_timer.start(1.0)
	
func _end_round():
	round_timer.stop()
	modifier_timer.stop()
	
	game_stats.computer_move = computer.pick_move(game_stats)
	var player_move: String = game_stats.player_move
	
	game_stats.outcome = _determine_outcome()
	
	$ModifierHandler.use_modifiers(game_stats, modifiers, ModifierBase.ApplyAt.ROUND_END)	
	_animate_used_modifiers()
	
	game_stats.record_round_stats()
	game_stats.apply_round_outcome()
		
	$RoundEnd.visible = true
	$MovesPicked.visible = true
	
	$TimeLeft.text = "00:00"
	$MovesPicked.text = "[color=white]You picked [color=gold]%s [color=white]against %s's [color=gold]%s" % [
		player_move.capitalize(),
		computer.display_name,
		game_stats.computer_move.capitalize()
	]
	
	if game_stats.outcome == GameStats.RoundOutcome.WIN:
		$RoundEnd.text = "You won the round! +%d points to you" % game_stats.get_points_on_win()
	elif game_stats.outcome == GameStats.RoundOutcome.LOSS:
		$RoundEnd.text = "You lost the round, +%d points to opponent" % game_stats.get_points_on_loss()
	elif game_stats.outcome == GameStats.RoundOutcome.DRAW:
		$RoundEnd.text = "Round draw, No points awarded"
	elif game_stats.outcome == GameStats.RoundOutcome.DISCARD:
		$RoundEnd.text = "Round has been discarded, No points awarded"
				
	_update_ui()
	
	for task in gamemode.task_pool:
		if task.timing != TaskBase.Timing.ROUND_END: continue
		
		var task_completed = task.check_completion(game_stats)
	
		if task_completed:
			print("%s has been completed!" % task.display_name)
		
	game_over = gamemode.is_game_over(game_stats)
		
	if game_over:
		$ActionButton.text = "End Game"
		$ActionButton.set_meta("Mode", "GameOver")
	else:
		$ActionButton.text = "Next Round"
		$ActionButton.set_meta("Mode", "NextRound")
	
	_toggle_move_btns(true)
	
func _end_game():
	for task in gamemode.task_pool:
		if task.timing != TaskBase.Timing.MATCH_END: continue
		
		var task_completed = task.check_completion(game_stats)
	
		if task_completed:
			print("%s has been completed!" % task.display_name)
	
	Signals.change_screen.emit("rps_results", {
		"stats": game_stats,
		"gamemode_name": gamemode.display_name,
		"opponent_name": computer.display_name,
		"modifier_count": modifiers.size()
	})

# Button & Siganl Connections
func _on_move_btn_pressed(btn: Button):
	if btn.disabled: return
	
	if not game_stats.player_move.is_empty():
		var old_btn: Button = move_btns.get_node(game_stats.player_move)
		old_btn.get_node("SelectedLabel").visible = false
	
	game_stats.player_move = btn.get_meta("Value")

	var selected_label = btn.get_node("SelectedLabel")
	if selected_label: selected_label.visible = true

func on_screen_change(information: Dictionary):
	gamemode = information.get("gamemode_resource")
	modifiers = information.get("modifier_resource")
	computer = information.get("computer_resource")
	
	_start_game()

func _on_modifier_timeout():
	$ModifierHandler.use_modifiers(game_stats, modifiers, ModifierBase.ApplyAt.EVERY_SECOND)
	_update_ui()

func _on_continue_btn_pressed():
	if game_over:
		_end_game()
	else:
		_start_round()
		
func _on_restart_btn_pressed():
	_restart_game()
	
func _on_quit_btn_pressed():
	_end_game()
	
func _on_action_btn_pressed():
	var mode: String = $ActionButton.get_meta("Mode")
	
	if mode == "RoundEnd":
		_end_round()
	elif mode == "GameOver":
		_end_game()
	elif mode == "NextRound":
		_start_round()
