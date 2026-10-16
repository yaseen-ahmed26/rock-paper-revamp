extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var skipped: bool = false

func _ready():
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
	Signals.change_screen.emit("main_menu")
	await get_tree().create_timer(0.3).timeout
	self.queue_free()
