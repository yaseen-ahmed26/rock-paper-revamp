extends GameplayEffect
class_name DamageEffect

@export var target: Target
@export var ignore_defense: bool = false
@export_range(1, 8, 1) var damage: int

func apply(game_stats: GameStats):
	var state: PlayerState = game_stats.player_state if target == Target.PLAYER else game_stats.computer_state

	state.take_bank_damage(damage, ignore_defense)
