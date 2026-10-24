extends GameplayTrigger
class_name CompareStatValueTrigger

@export var target_stat: GameStats.StatNames
@export var operator: Operator = Operator.EQUAL
@export var target_value: float = 0.0

func is_met(game_stats: GameStats):
	var current_value = game_stats.get(game_stats.get_lower_stat(target_stat))
	
	if current_value == null:
		push_warning("(CompareStatValueTrigger) '%s' is not a valid property in GameStats" % target_stat)
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
