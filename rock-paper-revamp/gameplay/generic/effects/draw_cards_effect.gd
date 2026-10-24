extends GameplayEffect
class_name DrawCardsEffect

@export var target: Target
@export_range(1, 8, 1) var amount_to_draw: int

func apply(game_stats: GameStats):
	var state: PlayerState = game_stats.player_state if target == Target.PLAYER else game_stats.computer_state
	
	state.draw_cards(amount_to_draw)
