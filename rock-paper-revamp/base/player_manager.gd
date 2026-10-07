extends Node

func calculate_tokens(game_stats: GameStats, modifiers: Array[ModifierBase], tasks_competed: int):
	var amount: int = 0
	
	amount += Constants.TOKENS_PER_GAME
	
	if game_stats.player_points > game_stats.computer_points:
		amount += Constants.TOKENS_ON_WIN
	else:
		amount += Constants.TOKENS_ON_LOSS
		
	amount += (modifiers.size() * Constants.TOKENS_PER_MODIFIER)
	amount += (tasks_competed * Constants.TOKENS_PER_TASK)
	
	SaveManager.save_data["tokens"] += amount
	
	return amount

func purchase_modifier(modifier: ModifierBase):
	if SaveManager.save_data.get("tokens") >= modifier.purchase_cost:
		var lower = ModifierBase.ID.keys()[modifier.id].to_lower()	

		SaveManager.save_data["tokens"] -= modifier.purchase_cost
		SaveManager.save_data["bought_modifiers"].append(lower)
		
		SaveManager.save_local()
		
		return true
	else:
		return false
