extends GameplayEffect
class_name DepleteProtectionEffect

@export var target: Target
@export_range(1, 5, 1) var amount: int

func apply(game_stats: GameStats):
	var state: PlayerState = game_stats.player_state if target == Target.PLAYER else game_stats.computer_state
	
	state._deplete_protection(amount)
