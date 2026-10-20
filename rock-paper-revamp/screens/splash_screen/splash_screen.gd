extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var skipped: bool = false

func _ready():
	await get_tree().process_frame
	
	if SaveManager.local_saved_settings.get("skip_splash"):
		skipped = true
		_proceed()
		return
	
	animation_player.play("splash")
	await animation_player.animation_finished
	
	if not skipped:
		_proceed()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			skipped = true
			_proceed()

func _proceed():
	if animation_player.is_playing():
		animation_player.pause()
	
	Signals.change_screen.emit("main_menu")
	await get_tree().create_timer(0.3).timeout
	self.queue_free()
