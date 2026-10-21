class_name PlayerState
extends RefCounted

const STARTING_BANK: int = 12
const STARTING_HAND_SIZE: int = 6
const MAX_HAND_SIZE: int = 8

var bank: int = STARTING_BANK
var defense: int = 0
var overshield: int = 0

var deck: Array[CardBase] = []
var hand: Array[CardBase] = []

func setup(card_pool: Array[CardBase]) -> void:
	bank = STARTING_BANK
	
	defense = 0
	overshield = 0
	
	deck = card_pool.duplicate()
	
	deck.shuffle()
	hand.clear()
	
	draw_initial_hand()

func draw_initial_hand() -> void:	
	for i in range(STARTING_HAND_SIZE):
		if hand.size() < MAX_HAND_SIZE and not deck.is_empty():
			hand.append(deck.pop_back())

func take_bank_damage(raw_damage: int, ignore_defense: bool = false) -> int:
	if raw_damage <= 0: return 0

	if ignore_defense:
		_deplete_protection(raw_damage)
		
		var unshielded_loss: int = mini(bank, raw_damage)
		bank -= unshielded_loss
		
		return unshielded_loss

	var blocked: int = mini((defense + overshield), raw_damage)
	
	_deplete_protection(blocked)

	var remaining_damage: int = raw_damage - blocked
	var actual_lost: int = mini(bank, remaining_damage)
	
	bank -= actual_lost
	
	return actual_lost

func _deplete_protection(amount: int) -> void:
	if amount <= 0: return
	
	var used_overshield: int = mini(overshield, amount)
	overshield -= used_overshield
	
	var left: int = amount - used_overshield
	defense = maxi(0, defense - left)

func decay_overshield() -> void:
	if overshield > 0: overshield -= 1

func consume_played_cards(turn_move: ChosenCards) -> void:
	for card in turn_move.get_played_cards():
		hand.erase(card)

func tutor_card_on_loss(deck_card_index: int, hand_discard_index: int = -1) -> bool:
	if deck.is_empty(): return false
	
	deck_card_index = clampi(deck_card_index, 0, deck.size() - 1)

	if hand.size() >= MAX_HAND_SIZE:
		hand_discard_index = clampi(hand_discard_index, 0, hand.size() - 1)
		hand.remove_at(hand_discard_index)

	hand.append(deck.pop_at(deck_card_index))
	
	return true

func claim_empty_hand_reward(choose_overshield: bool, overshield_bonus: int = 2, point_bonus: int = 2) -> void:
	if not hand.is_empty(): return
	
	if choose_overshield:
		overshield += overshield_bonus
	else:
		bank += point_bonus
		
	draw_initial_hand()

func has_no_cards() -> bool:
	return deck.is_empty() and hand.is_empty()
