extends ModifierTrigger
class_name StatComparisonTrigger

enum Operator {
	EQUAL,
	NOT_EQUAL,
	GREATER,
	GREATER_EQUAL,
	LESS,
	LESS_EQUAL
}

@export var target_stat: String
@export var operator: Operator = Operator.EQUAL
@export var target_value: float = 0.0

func is_met(game_stats: GameStats):
	var current_value = game_stats.get(target_stat)
	
	if current_value == null:
		push_warning("(StatComparisonTrigger) '%s' is not a valid property in GameStats" % target_stat)
		return false
	
	match operator:
		Operator.EQUAL:
			return current_value == target_value
		Operator.NOT_EQUAL:
			return current_value != target_value
		Operator.GREATER:
			return current_value > target_value
		Operator.GREATER_EQUAL:
			return current_value >= target_value
		Operator.LESS:
			return current_value < target_value
		Operator.LESS_EQUAL:
			return current_value <= target_value
			
	return false
