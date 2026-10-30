extends Node

signal move_chosen(chosen_cards: ChosenCards)

@export var action_btn: Button
@export var house_panel: Panel
@export var hand_panel: Panel
@export var match_meta_panel: Panel
@export var player_cards: Panel
@export var computer_cards: Panel
@export var player_health: Panel
@export var computer_health: Panel
@export var round_end: Panel

const MOVE_ICONS: Dictionary[CardBase.Suit, Texture] = {
	CardBase.Suit.ROCK: preload("res://assets/icons/rock.png"),
	CardBase.Suit.PAPER: preload("res://assets/icons/paper.png"),
	CardBase.Suit.SCISSORS: preload("res://assets/icons/scissors.png"),
	CardBase.Suit.LIZARD: preload("res://assets/icons/black_lock.png"),
	CardBase.Suit.SPOCK: preload("res://assets/icons/lock_white.png")
}

var chosen_cards: ChosenCards

# Godot
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

# Helpers
func _create_hand_cards(hand: Array[CardBase]):
	for card: CardBase in hand:
		_add_card_to_hand(card)
	
func _create_items_btns():
	pass

# Logic Helpers
func _remove_played_cards():
	pass

# General
func update_ui_general():
	pass

func _create_health_chunks(amount: int, colour: Color, chunk: Panel, holder):
	for i in range(amount):
		var clone = chunk.duplicate(true)
		holder.add_child(clone)
		clone.visible = true
		var new_stylebox: StyleBoxFlat = clone.get_theme_stylebox("panel").duplicate_deep()
		new_stylebox.bg_color = colour
		clone.add_theme_stylebox_override("panel", new_stylebox)

func _update_health_bars(game_stats: GameStats):	
	var p_container: HBoxContainer = player_health.get_node("HBoxContainer")
	var c_container: HBoxContainer = computer_health.get_node("HBoxContainer")
	var chunk: Panel = p_container.get_node("Chunk")
	
	var chunk_colours: Dictionary = {
		"bank": Color("facc15"),
		"defense": Color("38bdf8"),
		"shield": Color("e879f9")
	}
	
	for child in p_container.get_children():
		if child.name == "Chunk": continue
		child.queue_free()
	
	_create_health_chunks(game_stats.player_state.bank, chunk_colours.get("bank"), chunk, p_container)
	_create_health_chunks(game_stats.player_state.defense, chunk_colours.get("defense"), chunk, p_container)
	_create_health_chunks(game_stats.player_state.overshield, chunk_colours.get("shield"), chunk, p_container)
	
	for child in c_container.get_children():
		if child.name == "Chunk": continue
		child.queue_free()
	
	_create_health_chunks(game_stats.computer_state.overshield, chunk_colours.get("shield"), chunk, c_container)
	_create_health_chunks(game_stats.computer_state.defense, chunk_colours.get("defense"), chunk, c_container)
	_create_health_chunks(game_stats.computer_state.bank, chunk_colours.get("bank"), chunk, c_container)
	
func _reset_timer():
	pass

func _reset_card_stacks():	
	player_cards.get_node("Lead").visible = false
	player_cards.get_node("LeadOutline").visible = true
	
	player_cards.get_node("Chain").visible = false
	player_cards.get_node("ChainOutline").visible = false
	
	player_cards.get_node("Special").visible = false
	player_cards.get_node("SpecialOutline").visible = false

func _add_card_to_hand(card: CardBase) -> void:
	var holder: HBoxContainer = hand_panel.get_node("ScrollContainer/VBoxContainer")
	var template_card_scene: PackedScene = load("res://screens/loop_game/template_card/template_card.tscn")
	
	var clone = template_card_scene.instantiate()
	holder.add_child(clone)
	
	clone.ui_handler = self
	
	clone.call("setup", card, MOVE_ICONS.get(card.suit))
	
func _update_specific_card(card_base: CardBase, type: String):
	var card = player_cards.get_node(type)

	card.visible = true
	
	card.get_node("SuitIcon").texture = MOVE_ICONS.get(card_base.suit)
	card.get_node("Suit").text = card_base.get_suit_name().to_upper()
	card.get_node("Weight").text = "%s [%d]" % [CardBase.Weight.keys()[card_base.weight].to_upper(), card_base.weight]
	
func _recheck_chain_validity():
	var card: Panel = player_cards.get_node("Chain")
	var outline: Panel = player_cards.get_node("ChainOutline")
	
	if not chosen_cards.chain_card: 
		outline.visible = true
		return
	
	if not chosen_cards.can_set_chain(chosen_cards.chain_card):
		outline.visible = true
		card.visible = false
		_add_card_to_hand(chosen_cards.chain_card)
		
		chosen_cards.chain_card = null

# Main Game Functions
func on_game_start(game_stats: GameStats):
	_create_hand_cards(game_stats.player_state.hand)
	
func on_game_end():
	pass

func on_round_start(game_stats: GameStats):
	var current_house_suit: Panel = house_panel.get_node("CurrentSuit")	
	var next_house_suit: Panel = house_panel.get_node("NextSuit")	
	var house_bank: RichTextLabel = house_panel.get_node("Bank")	
	var rounds_played: RichTextLabel = match_meta_panel.get_node("RoundsPlayed")

	current_house_suit.get_node("Icon").texture = MOVE_ICONS.get(game_stats.house_suit)
	current_house_suit.get_node("Label").text = game_stats.get_lower_suit(game_stats.house_suit).to_upper()
	
	next_house_suit.get_node("Icon").texture = MOVE_ICONS.get(game_stats.next_house_suit)
	next_house_suit.get_node("Label").text = game_stats.get_lower_suit(game_stats.next_house_suit).to_upper()
	
	house_bank.text = "Bank: %d" % game_stats.house_bank
	rounds_played.text = "[color=#c084fc]ROUND[/color] %d / %s" % [
		game_stats.rounds_played,
		str(game_stats.total_rounds) if game_stats.total_rounds != -1 else "inf"
	]
	
	var tween: Tween = create_tween()
	tween.tween_property(round_end, "modulate:a", 0.0, 0.5)
	
	_reset_timer()
	_reset_card_stacks()
	_update_health_bars(game_stats)
	
	chosen_cards = ChosenCards.new()
	
func on_round_end(game_stats: GameStats):
	on_round_start(game_stats)
	
	round_end.get_node("Label").text = game_stats.last_round_summary
	
	var tween: Tween = create_tween()
	tween.tween_property(round_end, "modulate:a", 1.0, 0.5)

# Connections
func try_play_card(card: CardBase, slot_type: String):
	match slot_type:
		"lead":
			if card.is_special: return false
			
			if chosen_cards.lead_card:
				_add_card_to_hand(chosen_cards.lead_card)
			
			chosen_cards.lead_card = card
			
			_update_specific_card(card, slot_type.capitalize())
			_recheck_chain_validity()
			
			return true
		"chain":
			if card.is_special: return false
			
			if chosen_cards.can_set_chain(card):
				if chosen_cards.chain_card:
					_add_card_to_hand(chosen_cards.chain_card)
				
				chosen_cards.chain_card = card
				
				_update_specific_card(card, slot_type.capitalize())
	
				return true
			else:
				return false
	
	return false

func _on_action_button_pressed() -> void:
	var state: String = action_btn.get_meta("State")
	
	if state == "EndRound":
		owner.submit_moves(chosen_cards)
		action_btn.set_meta("State", "NextRound")
		action_btn.text = "Next Round"
	elif state == "NextRound":
		owner.start_round()
		action_btn.set_meta("State", "EndRound")
		action_btn.text = "End Round"
