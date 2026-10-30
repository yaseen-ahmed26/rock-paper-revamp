extends GameplayEffect
class_name ChangeHouseSuitEffect

## If true, randomise the House Suit.
@export var randomise: bool = false
## The new suit to change to. Note this always changes the House to this suit.
@export var new_suit: CardBase.Suit

func apply(game_stats: GameStats):
	if randomise:
		game_stats.house_suit = game_stats.pick_random_suit()
	else:
		game_stats.house_suit = new_suit if new_suit else game_stats.pick_random_suit() 
