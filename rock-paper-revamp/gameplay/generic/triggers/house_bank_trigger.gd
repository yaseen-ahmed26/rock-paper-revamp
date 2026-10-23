extends GameplayTrigger
class_name HouseBankTrigger

## The operator to use when comparing.
@export var operator: Operator
## The value to compare the House Bank against.
@export_range(0, 30, 1) var target_value: int

func is_met(game_stats: GameStats):
	match operator:
		Operator.EQUAL:
			return game_stats.house_bank == target_value
		Operator.NOT_EQUAL:
			return game_stats.house_bank != target_value
		Operator.GREATER:
			return game_stats.house_bank > target_value
		Operator.GREATER_EQUAL:
			return game_stats.house_bank >= target_value
		Operator.LESS:
			return game_stats.house_bank < target_value
		Operator.LESS_EQUAL:
			return game_stats.house_bank <= target_value
			
	return false
