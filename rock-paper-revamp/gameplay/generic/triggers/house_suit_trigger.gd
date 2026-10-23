extends GameplayTrigger
class_name HouseSuitTrigger

enum Scope {
	CURRENT_SUIT,
	NEXT_SUIT
}

## Which suit to check for.
@export var scope: Scope
## Which move to check for.
@export var move: CardBase.Suit

func is_met(game_stats: GameStats):
	if scope == Scope.CURRENT_SUIT:
		return game_stats.house_suit == move
	elif scope == Scope.NEXT_SUIT:
		return game_stats.next_house_suit == move
