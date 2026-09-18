extends ModifierTrigger
class_name PointDifferenceTrigger

enum Target {
	AI, 
	PLAYER
}
enum Position {
	WINNING,
	LOSING
}

@export var target: Target
@export var position: Position
@export var how_much_by: float = 0.0

func is_met(game_stats: GameStats):
	var p_points = game_stats.player_points
	var a_points = game_stats.computer_points
	
	var difference = (p_points - a_points) if target == Target.PLAYER else (a_points - p_points)
	
	match position:
		Position.WINNING:
			return difference >= how_much_by
		Position.LOSING:
			return difference <= -how_much_by
			
	return false
