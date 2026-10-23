extends GameplayTrigger
class_name CardWeightTrigger

## If true, consider the chained card's weight.
@export var consider_chain_card: bool = false
## The player to check the weight of the chosen cards.
@export var target: Target
## The operator to use when comparing.
@export var operator: Operator
## The value to compare the weight against.
@export_range(0, 30, 1) var target_value: int

func is_met(game_stats: GameStats):
	var use_weight: int
	var cards: ChosenCards = game_stats.player_turn_move if target == Target.PLAYER else game_stats.computer_turn_move
	
	if consider_chain_card:
		use_weight = cards.get_total_weight()
	else:
		use_weight = cards.lead_card.get_weight_value()
		
	match operator:
		Operator.EQUAL:
			return use_weight == target_value
		Operator.NOT_EQUAL:
			return use_weight != target_value
		Operator.GREATER:
			return use_weight > target_value
		Operator.GREATER_EQUAL:
			return use_weight >= target_value
		Operator.LESS:
			return use_weight < target_value
		Operator.LESS_EQUAL:
			return use_weight <= target_value
