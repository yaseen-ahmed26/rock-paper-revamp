extends GameplayTrigger
class_name CardPlayedTrigger

## The player to check the weight of the chosen cards.
@export var target: Target
## If true, then the target must have played a chain card.
@export var require_chain: bool = false
## If true, then the target must have played a special card.
@export var require_special: bool = false

func is_met(game_stats: GameStats):
	var cards: ChosenCards = game_stats.player_turn_move if target == Target.PLAYER else game_stats.computer_turn_move
		
	if require_chain and cards.chain_card == null:
		return false
	if require_special and cards.special_card == null:
		return false
		
	return true
