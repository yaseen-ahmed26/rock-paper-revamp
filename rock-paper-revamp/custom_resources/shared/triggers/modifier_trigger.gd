extends GameplayTrigger
class_name ModifierUsageTrigger

enum Scope {
	## Looks at the global game to see how many times the modifier was used.
	WHOLE_MATCH,
	## Looks to see if the modifier was applied this round (usually once).
	CURRENT_ROUND_ONLY
}

enum Operator {
	EQUAL,
	GREATER_EQUAL,
	LESS_EQUAL
}

@export var target_modifier: ModifierBase.ID
@export var scope: Scope = Scope.WHOLE_MATCH
## The operator to comapre with.
@export var operator: Operator = Operator.GREATER_EQUAL
## How many times the target modifier needed to have been used. Set as 0 for "never activated" and 1 or more for multiple.
@export var count: int = 1

func is_met(game_stats: GameStats) -> bool:
	var activations: int = 0
	
	match scope:
		Scope.WHOLE_MATCH:
			activations = game_stats.modifier_usage_count.get(target_modifier, 0)
		Scope.CURRENT_ROUND_ONLY:
			activations = 1 if target_modifier in game_stats.round_activated_modifiers else 0

	match operator:
		Operator.EQUAL:
			return activations == count
		Operator.GREATER_EQUAL:
			return activations >= count
		Operator.LESS_EQUAL:
			return activations <= count
			
	return false
