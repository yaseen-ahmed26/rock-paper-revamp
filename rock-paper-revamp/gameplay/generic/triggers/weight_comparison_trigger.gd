extends GameplayTrigger
class_name WeightComparisonTrigger

@export var operator: Operator

func is_met(game_stats: GameStats):
	var player_weight = game_stats.player_turn_move.get_total_weight()
	var computer_weight = game_stats.computer_turn_move.get_total_weight()
	
	match operator:
		Operator.EQUAL:
			return player_weight == computer_weight
		Operator.NOT_EQUAL:
			return player_weight != computer_weight
		Operator.GREATER:
			return player_weight > computer_weight
		Operator.GREATER_EQUAL:
			return player_weight >= computer_weight
		Operator.LESS:
			return player_weight < computer_weight
		Operator.LESS_EQUAL:
			return player_weight <= computer_weight
			
	return false
