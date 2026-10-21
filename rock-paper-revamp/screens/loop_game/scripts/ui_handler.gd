extends Node

signal move_chosen(chosen_cards: ChosenCards)

@onready var player_hand_holder: HBoxContainer = $"../PlayerHand"

var chosen_cards: ChosenCards

func _ready() -> void:
	chosen_cards = ChosenCards.new()
	
func _create_cards(hand: Array[CardBase]):
	var template_card: Panel = player_hand_holder.get_node("TemplateCard")
		
	for card: CardBase in hand:
		var clone: Panel = template_card.duplicate(true)
		
		player_hand_holder.add_child(clone)
		clone.visible = true
		clone.name = str(card.id)
		
		clone.get_node("Suit").text = "Suit: " + card.get_suit_name()
		clone.get_node("Weight").text = "Weight: " + CardBase.Weight.keys()[card.weight].to_lower()
		
		clone.get_node("SetLead").pressed.connect(_on_set_lead_btn_pressed.bind(clone))
		clone.get_node("SetChain").pressed.connect(_on_set_chain_btn_pressed.bind(clone))
		
		clone.set_meta("CardBase", card.duplicate(true))

func _update_card_status():
	for child: Panel in player_hand_holder.get_children():
		if child.name == "TemplateCard": continue
		
		var card_base: CardBase = child.get_meta("CardBase")

		if chosen_cards.can_set_chain(card_base):
			child.get_node("SetChain").disabled = false
		else:
			child.get_node("SetChain").disabled = true

func _on_set_lead_btn_pressed(card_panel: Panel):
	var card_base: CardBase = card_panel.get_meta("CardBase")

	chosen_cards = ChosenCards.new()
	
	chosen_cards.set_lead(card_base)
	
	$"../SubmitMoves".disabled = false
	
	_update_card_status()
	
func _on_set_chain_btn_pressed(card_panel: Panel):
	var card_base: CardBase = card_panel.get_meta("CardBase")
	
	chosen_cards.set_chain(card_base)

func _on_submit_moves_pressed() -> void:
	move_chosen.emit(chosen_cards)

func set_inital_ui(game_stats: GameStats):
	$"../HouseSuits".visible = true
	$"../RoundsPlayed".visible = true
	$"../Banks".visible = true
	
	$"../HouseSuits".text = "House Suit: %s • Next Suit: %s" % [game_stats.house_suit, game_stats.next_house_suit]
	$"../RoundsPlayed".text = "Rounds Played: %d/%s" % [game_stats.rounds_played, str(game_stats.total_rounds) if game_stats.total_rounds != -1 else "∞"]
	$"../Banks".text = "Player Bank: %d • Computer Bank: %d • House Bank: %d" % [
		game_stats.player_state.bank,
		game_stats.computer_state.bank,
		game_stats.house_bank
	]
	
	_create_cards(game_stats.player_state.hand)

func set_round_start_ui(game_stats: GameStats):
	$"../HouseSuits".text = "House Suit: %s • Next Suit: %s" % [game_stats.house_suit, game_stats.next_house_suit]
	$"../RoundsPlayed".text = "Rounds Played: %d/%s" % [game_stats.rounds_played, str(game_stats.total_rounds) if game_stats.total_rounds != -1 else "∞"]
	$"../Banks".text = "Player Bank: %d • Computer Bank: %d • House Bank: %d" % [
		game_stats.player_state.bank,
		game_stats.computer_state.bank,
		game_stats.house_bank
	]
	
	$"../RoundOutcome".visible = false
	$"../ComputerPlayed".visible = false

func set_round_end_ui(game_stats: GameStats):
	set_round_start_ui(game_stats)
	
	$"../RoundOutcome".text = game_stats.last_round_summary
