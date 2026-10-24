extends GameplayTrigger
class_name CompareStatsTrigger

@export var target_stat_a: GameStats.StatNames
@export var target_stat_b: GameStats.StatNames
@export var operator: Operator = Operator.EQUAL

func is_met(game_stats: GameStats):
	var current_value_a = game_stats.get(game_stats.get_lower_stat(target_stat_a))
	var current_value_b = game_stats.get(game_stats.get_lower_stat(target_stat_b))
	
	if current_value_a == null or current_value_b == null:
		push_warning("(CompareStatsTrigger) Invalid stats to compare.")
		return false
	
	match operator:
		Operator.EQUAL:
			return current_value_a == current_value_b
		Operator.NOT_EQUAL:
			return current_value_a != current_value_b
		Operator.GREATER:
			return current_value_a > current_value_b
		Operator.GREATER_EQUAL:
			return current_value_a >= current_value_b
		Operator.LESS:
			return current_value_a < current_value_b
		Operator.LESS_EQUAL:
			return current_value_a <= current_value_b
			
	return false
