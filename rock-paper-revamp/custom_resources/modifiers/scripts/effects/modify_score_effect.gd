extends ModifierEffect
class_name ModifyScoreEffect

enum Target {
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
@export var target: Target
## The method to apply the value
@export var operation: StatChange.Operation
## The value to update the score
@export var value: float

func apply(game_stats: GameStats):
	print("a")
	var p_stat_change: StatChange = StatChange.new()
	var a_stat_change: StatChange = StatChange.new()
	
	p_stat_change.operation = operation
	a_stat_change.operation = operation
	
	p_stat_change.value = value
	a_stat_change.value = value
	
	p_stat_change.target_stat = "player_points"
	a_stat_change.target_stat = "computer_points"
	
	match target:
		Target.PLAYER:
			game_stats.apply_stat_change(p_stat_change)
		Target.AI:
			game_stats.apply_stat_change(a_stat_change)
		Target.BOTH:
			game_stats.apply_stat_change(p_stat_change)
			game_stats.apply_stat_change(a_stat_change)
		Target.LEADER:
			if game_stats.player_points < game_stats.computer_points:
				game_stats.apply_stat_change(a_stat_change)
			elif game_stats.player_points > game_stats.computer_points:
				game_stats.apply_stat_change(p_stat_change)
		Target.LOSER:
			if game_stats.player_points > game_stats.computer_points:
				game_stats.apply_stat_change(a_stat_change)
			elif game_stats.player_points < game_stats.computer_points:
				game_stats.apply_stat_change(p_stat_change)
