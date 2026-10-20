extends GameplayTrigger
class_name InternalModifierTrigger

enum Operator {
	EQUAL,
	NOT_EQUAL,
	GREATER,
	GREATER_EQUAL,
	LESS,
	LESS_EQUAL
}

@export var operator: Operator = Operator.EQUAL
@export var target_value: int = 0

func is_met(internal_state: ModifierInternal):
	var current_value = internal_state.charges
	
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
