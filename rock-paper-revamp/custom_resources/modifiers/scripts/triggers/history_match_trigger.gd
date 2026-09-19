extends ModifierTrigger
class_name HistoryMatchTrigger

enum CompareWith {
	SAME_AS_AI,
	SAME_AS_PLAYER
}

@export var comparison: CompareWith

func is_met(game_stats: GameStats) -> bool:
	var history = game_stats.computer_history if comparison == CompareWith.SAME_AS_AI else game_stats.player_history
	return game_stats.player_move == history[-1]
