extends Node

func _ready() -> void:
	_create_cards()
	
func _create_cards():
	var pool = ContentManager.cards.values().duplicate_deep()
	pool.sort_custom(func(a, b): return a.suit < b.suit)
	
	for card: CardBase in pool:
		print(card.display_name)
