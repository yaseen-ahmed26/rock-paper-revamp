extends GamemodeBase

func is_game_over(game_stats: GameStats):
	if game_stats.player_state.bank == 3:
		print("END GAME")
		return true
		
	return false

func on_hand_emptied(_game_stats: GameStats, _is_player: bool):
	return false
