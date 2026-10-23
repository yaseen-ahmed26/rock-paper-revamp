extends GameplayTrigger
class_name HonestMoveTrigger

## The player to check for.
@export var target: Target

func is_met(game_stats: GameStats):
	match target:
		Target.PLAYER:
			return game_stats.current_round.player_played_honest
		Target.AI:
			return game_stats.current_round.computer_played_honest
