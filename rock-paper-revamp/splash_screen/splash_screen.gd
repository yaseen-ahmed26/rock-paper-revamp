extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	animation_player.play("splash")
	await animation_player.animation_finished
	Signals.change_screen.emit("main_menu")
	self.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			animation_player.pause()
			Signals.change_screen.emit("main_menu")
			self.queue_free()
