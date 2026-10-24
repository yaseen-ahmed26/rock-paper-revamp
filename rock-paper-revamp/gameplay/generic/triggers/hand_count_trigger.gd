extends GameplayTrigger
class_name HandCountTrigger

@export var target: Target
@export var operator: Operator
@export_range(0, 8, 1) var amount: int

func is_met(game_stats: GameStats):
	var state: PlayerState = game_stats.player_state if target == Target.PLAYER else game_stats.computer_state
	var hand_count = state.hand.size()
	
	match operator:
		Operator.EQUAL:
			return hand_count == amount
		Operator.NOT_EQUAL:
			return hand_count != amount
		Operator.GREATER:
			return hand_count > amount
		Operator.GREATER_EQUAL:
			return hand_count >= amount
		Operator.LESS:
			return hand_count < amount
		Operator.LESS_EQUAL:
			return hand_count <= amount
			
	return false
