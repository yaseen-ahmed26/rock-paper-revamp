extends GameplayTrigger
class_name MoveTypeTrigger

enum Type {
	HONEST,
	SNIPE
}

@export var target: Target
@export var type: Type

func is_met(game_stats: GameStats):
	var played_move = game_stats.current_round.player_played_honest if target == Target.PLAYER else game_stats.current_round.computer_played_honest
	
	if type == Type.HONEST and played_move:
		return true
		
	if type == Type.SNIPE and not played_move:
		return true

	return false
