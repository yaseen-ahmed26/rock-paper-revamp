extends GameplayTrigger
class_name CardSuitTrigger

## The suit to check for.
@export var suit: CardBase.Suit
## The player to look at.
@export var target: Target

func is_met(game_stats: GameStats):
	return game_stats.player_turn_move.get_effective_suit() == suit
