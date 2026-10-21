extends Node

signal move_chosen(chosen_cards: ChosenCards)

@onready var player_hand_holder: HBoxContainer = $"../PlayerHand"

var chosen_cards: ChosenCards

func _ready() -> void:
	chosen_cards = ChosenCards.new()
	
func set_ui(game_stats: GameStats):
	var template_card: Panel = player_hand_holder.get_node("TemplateCard")
		
	for card: CardBase in game_stats.player_state.hand:
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
