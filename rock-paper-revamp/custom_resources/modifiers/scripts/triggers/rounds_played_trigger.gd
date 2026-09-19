extends ModifierTrigger
class_name RoundsPlayedTrigger

enum Type {
	DELAY_BY,
	APPLY_UNTIL
}

@export var type: Type
@export var rounds: int = 0

func is_met(game_stats: GameStats):
	match type:
		Type.DELAY_BY:
			return rounds <= game_stats.rounds_played
		Type.APPLY_UNTIL:
			return rounds >= game_stats.rounds_played
	
	return false
