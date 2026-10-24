extends GameplayTrigger
class_name MoveTypeTrigger

enum Type {
	HONEST,
	SNIPE
}

@export var target: Target
@export var type: Type

func is_met(game_stats: GameStats):
	if type == Type.HONEST:
		return game_stats.current_round.player_played_honest 
