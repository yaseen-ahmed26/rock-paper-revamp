extends GameplayTrigger
class_name CardSuitTrigger

## The suit to check for.
@export var suit: CardBase.Suit
## The player to look at.
@export var target: Target

func is_met(game_stats: GameStats):
	var state: PlayerState = game_stats.player_state if target == Target.PLAYER else game_stats.computer_state

	return state.get_effective_suit() == suit
