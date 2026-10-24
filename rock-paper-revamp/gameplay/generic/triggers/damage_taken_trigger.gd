extends GameplayTrigger
class_name DamageTakenTrigger

enum DamageType {
	ACTUAL_BANK_LOST,
	RAW_INCOMING,
	BLOCKED_BY_SHIELD 
}

@export var target: Target
@export var damage_type: DamageType
@export var operator: Operator
@export_range(0, 30, 1) var threshold: int

func is_met(game_stats: GameStats):
	var damage: int
	
	if target == Target.PLAYER:
		match damage_type:
			DamageType.ACTUAL_BANK_LOST:
				damage = game_stats.current_round.player_actual_points_lost
			DamageType.RAW_INCOMING:
				damage = game_stats.current_round.player_raw_damage_taken
			DamageType.BLOCKED_BY_SHIELD:
				damage = game_stats.current_round.player_damage_blocked
	else:
		match damage_type:
			DamageType.ACTUAL_BANK_LOST:
				damage = game_stats.current_round.computer_actual_points_lost
			DamageType.RAW_INCOMING:
				damage = game_stats.current_round.computer_raw_damage_taken
			DamageType.BLOCKED_BY_SHIELD:
				damage = game_stats.current_round.computer_damage_blocked

	match operator:
		Operator.EQUAL: return damage == threshold
		Operator.NOT_EQUAL: return damage != threshold
		Operator.GREATER: return damage > threshold
		Operator.GREATER_EQUAL: return damage >= threshold
		Operator.LESS: return damage < threshold
		Operator.LESS_EQUAL: return damage <= threshold

	return false
