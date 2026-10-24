extends GameplayEffect
class_name RefillHandEffect

func apply(game_stats: GameStats):
	game_stats.player_state.refill_hand()
