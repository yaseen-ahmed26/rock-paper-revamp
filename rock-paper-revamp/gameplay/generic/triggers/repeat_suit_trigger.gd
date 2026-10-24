extends GameplayTrigger
class_name RepeatSuitTrigger

func is_met(game_stats):
	var current_suit = game_stats.player_turn_move.lead_card.suit 
	var previous_suit = game_stats.previous_rounds[-1].player_lead_card.suit
	
	return current_suit == previous_suit
