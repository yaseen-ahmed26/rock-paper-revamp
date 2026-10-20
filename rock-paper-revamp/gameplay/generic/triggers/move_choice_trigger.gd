extends GameplayTrigger
class_name MoveChoiceTrigger

enum Target {
	PLAYER, 
	AI
}

@export var target: Target
@export var required_move: String

func is_met(game_stats: GameStats):
	var stat = game_stats.player_move if target == Target.PLAYER else game_stats.computer_move
	return required_move == stat
