extends GameplayTrigger
class_name DefenseBrokenTrigger

@export var target: Target

func is_met(game_stats: GameStats):
	return game_stats.current_round.player_defense_broken if target == Target.PLAYER else game_stats.current_round.computer_defense_broken
