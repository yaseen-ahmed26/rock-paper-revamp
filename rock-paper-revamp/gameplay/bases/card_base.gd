class_name CardBase
extends DescribedBase

const SHOW_IF: Dictionary = {
	"!is_special": ["suit", "weight"],
	"is_special": ["weight_requirement", "special_effects"]
}

enum Suit {
	NONE,
	ROCK,
	PAPER,
	SCISSORS,
	LIZARD,
	SPOCK
}

enum Weight {
	NONE,
	LIGHT,
	REGULAR,
	MODERATE,
	HEAVY,
	COLOSSAL
}

@export_group("Flags")
## If true, then suit and weights are discarded and this card plays a special effect when used.
@export var is_special: bool = false

@export_group("Advanced")
## The suit of this card.
@export var suit: Suit = Suit.ROCK
## The weight of this card.
@export var weight: Weight = Weight.LIGHT
## For specials, how much combined weight this card requires to play. Includes Lead + Chain weight.
@export var weight_requirement: int = 3
## For specials, he array of special effects this applies.
@export var special_effects: Array[GameplayEffect] = []

func get_weight_value():
	return Weight.NONE if is_special else int(weight)

func get_suit_name():
	if is_special or suit == Suit.NONE:
		return "none"
	
	return Suit.keys()[suit].to_lower()
