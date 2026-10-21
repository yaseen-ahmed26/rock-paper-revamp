class_name ChosenCards
extends RefCounted

var lead_card: CardBase = null
var chain_card: CardBase = null
var special_card: CardBase = null

# Testing
var override_suit: CardBase.Suit = CardBase.Suit.NONE
var override_weight: int = -1

static func from_raw(p_suit: CardBase.Suit, p_weight: int) -> ChosenCards:
	var move: ChosenCards = ChosenCards.new()
	
	move.override_suit = p_suit
	move.override_weight = p_weight
	
	return move

func set_lead(card: CardBase) -> bool:
	if card.is_special or card.suit == CardBase.Suit.NONE: return false
	
	lead_card = card
	chain_card = null
	special_card = null
	
	return true

func can_set_chain(card: CardBase) -> bool:
	if lead_card == null or card.is_special: return false
	
	var counters_lead: bool = GameStats.does_suit_beat(card.suit, lead_card.suit)
	var valid_weight: bool = card.get_weight_value() <= lead_card.get_weight_value()
	
	return counters_lead and valid_weight

func set_chain(card: CardBase) -> bool:
	if not can_set_chain(card): return false
		
	chain_card = card
	
	if special_card and not can_set_special(special_card):
		special_card = null
	
	return true

func can_set_special(card: CardBase) -> bool:
	if lead_card == null or card == null or not card.is_special: return false

	return get_total_weight() >= card.weight_requirement

func set_special(card: CardBase) -> bool:
	if not can_set_special(card): return false
	
	special_card = card
	
	return true

func get_effective_suit() -> CardBase.Suit:
	if override_suit != CardBase.Suit.NONE: return override_suit
	
	return lead_card.suit if lead_card != null else CardBase.Suit.NONE

func get_total_weight() -> int:
	if override_weight >= 0: return override_weight
	if lead_card == null: return 0
	
	var total: int = lead_card.get_weight_value()
	
	if chain_card != null:
		total += chain_card.get_weight_value()
	
	return total

func get_played_cards() -> Array[CardBase]:
	var used: Array[CardBase] = []
	
	if lead_card: used.append(lead_card)
	if chain_card: used.append(chain_card)
	if special_card: used.append(special_card)
	
	return used

func get_full_card_details():
	var details: Array = []
	
	if lead_card:
		details.append(
		{
			"suit": lead_card.get_suit_name(),
			"weight": lead_card.get_weight_name()
		})
		
	if chain_card:
		details.append(
		{
			"suit": chain_card.get_suit_name(),
			"weight": chain_card.get_weight_name()
		})
	
	return details
