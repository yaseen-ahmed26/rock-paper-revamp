extends Node

var active_contract = {
	"id": &"",
	"base": null,
	"total_tasks": 0,
	"progress": {},
	"completed": false,
	"reward_claimed": false
}

func _ready() -> void:
	set_contract_active(ContentManager.get_contract_resource(&"test_contract"))
	
func calculate_tokens(game_stats: GameStats, modifiers: Array[ModifierBase], tasks_competed: int):
	var amount: int = 0
	
	amount += Constants.TOKENS_PER_GAME
	
	if game_stats.player_points > game_stats.computer_points:
		amount += Constants.TOKENS_ON_WIN
	else:
		amount += Constants.TOKENS_ON_LOSS
		
	amount += (modifiers.size() * Constants.TOKENS_PER_MODIFIER)
	amount += (tasks_competed * Constants.TOKENS_PER_TASK)
	
	# SaveManager.local_saved_data["tokens"] += amount
	
	return amount

func purchase_modifier(modifier: ModifierBase):
	if SaveManager.local_saved_data.get("tokens") >= modifier.purchase_cost:
		SaveManager.local_saved_data["tokens"] -= modifier.purchase_cost
		SaveManager.local_saved_data["bought_modifiers"].append(modifier.id)
		
		SaveManager.save_local()
		
		return true
	else:
		return false

func set_contract_active(contract: ContractBase):
	# Would also need to check if it's been completed.

	active_contract.base = contract
	active_contract.completed = false
	active_contract.reward_claimed = false
	
	active_contract.id = contract.id
	active_contract.total_tasks = contract.subtasks.size()
	
	for subtask: ContractSubtask in contract.subtasks:
		active_contract.progress[contract.subtasks.find(subtask)] = {
			"progress_made": 0,
			"progress_needed": subtask.completion_amount,
			"completed": false
		}

func check_contract_completion(game_stats: GameStats, timing: ModifierBase.ApplyAt):
	if active_contract.completed: return
	
	var contract: ContractBase = active_contract.base
	var tasks_completed: int = 0
	
	for subtask: ContractSubtask in contract.subtasks:
		var task_index: int = contract.subtasks.find(subtask)
		var saved_progress: Dictionary = active_contract.progress.get(task_index)
		
		if saved_progress.get("completed"):
			tasks_completed += 1	
			continue
		
		if subtask.check_completion(game_stats, timing):			
			saved_progress.progress_made += 1
			
			if saved_progress.progress_made >= saved_progress.progress_needed:
				saved_progress.completed = true
				tasks_completed += 1		
		
	if tasks_completed == active_contract.get("total_tasks"):
		active_contract.completed = true

func get_total_completed_tasks():
	var completed: int = 0
	
	for t in active_contract.progress.values():
		if t.completed: completed += 1
		
	return completed
