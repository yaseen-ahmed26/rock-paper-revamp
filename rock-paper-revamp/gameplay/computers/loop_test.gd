extends ComputerBase
class_name LoopTestComputer

const SHOW_IF: Dictionary = {
	"override_choice": ["suit", "weight"]
}

@export_group("Flags")
@export var override_choice: bool = false

@export_group("Advanced")
@export var suit: CardBase.Suit
@export var weight: CardBase.Weight

func pick_move(stats: GameStats) -> ChosenCards:
	var self_state: PlayerState = stats.computer_state
	
	var chosen_cards: ChosenCards = ChosenCards.new()
	
	if override_choice:
		var new_card: CardBase = CardBase.new()
		new_card.suit = suit
		new_card.weight = weight
		
		chosen_cards.set_lead(new_card)
	else:
		chosen_cards.set_lead(self_state.hand.pick_random())
	
	return chosen_cards
