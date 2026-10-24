extends GameplayEffect
class_name ModifyScoreEffect

enum PropietaryTarget {
	## Apply the change to the player
	PLAYER,
	## Apply the change to the AI
	AI,
	## Apply to both the player and AI
	BOTH,
	## Apply to whoever is leading
	LEADER,
	## Apply to whoever is losing
	LOSER
}

## Who the point change should be applied to.
@export var target: PropietaryTarget
## The method to apply the value
@export var operation: StatChange.Operation
## The value to update the score
@export var value: float

func apply(game_stats: GameStats):
	var p_stat_change: StatChange = StatChange.new()
	var a_stat_change: StatChange = StatChange.new()
	
	p_stat_change.operation = operation
	a_stat_change.operation = operation
	
	p_stat_change.value = value
	a_stat_change.value = value
	
	p_stat_change.target_stat = GameStats.StatNames.PLAYER_POINTS
	a_stat_change.target_stat = GameStats.StatNames.COMPUTER_POINTS
	
	match target:
		PropietaryTarget.PLAYER:
			game_stats.apply_stat_change(p_stat_change)
		PropietaryTarget.AI:
			game_stats.apply_stat_change(a_stat_change)
		PropietaryTarget.BOTH:
			game_stats.apply_stat_change(p_stat_change)
			game_stats.apply_stat_change(a_stat_change)
		PropietaryTarget.LEADER:
			if game_stats.player_points < game_stats.computer_points:
				game_stats.apply_stat_change(a_stat_change)
			elif game_stats.player_points > game_stats.computer_points:
				game_stats.apply_stat_change(p_stat_change)
		PropietaryTarget.LOSER:
			if game_stats.player_points > game_stats.computer_points:
				game_stats.apply_stat_change(a_stat_change)
			elif game_stats.player_points < game_stats.computer_points:
				game_stats.apply_stat_change(p_stat_change)
