extends Control

@onready var contracts_holder: Panel = $ContractsHolder
@onready var selected_contract: Panel = $SelectedContract
@onready var grid_container: GridContainer = $ContractsHolder/ScrollContainer/GridContainer
@onready var information_banner: Panel = $InformationBanner

var chosen_contract: ContractBase

func _ready() -> void:
	_set_inital()
	_create_btns()
	
func _set_inital():
	information_banner.get_node("Completed").text = "[color=#94a3b8]COMPLETED:[/color] [color=#34d399]0 / %d[/color]" % [ContentManager.contracts.size()]
	
	if PlayerManager.active_contract.base != null:
		information_banner.get_node("CurrentContract").text = "[color=#a855f7]ACTIVE CONTRACT:[/color] [color=#ffffff]%s[/color] • [color=#94a3b8]%d/%d TASKS COMPLETED[/color]" % [
			PlayerManager.active_contract.base.display_name,
			PlayerManager.get_total_completed_tasks(),
			PlayerManager.active_contract.base.subtasks.size()
		]
	else:
		information_banner.get_node("CurrentContract").text = "[color=#a855f7]ACTIVE CONTRACT:[/color] [color=#ffffff]NONE[/color]"

func _create_btns():
	var template_active = grid_container.get_node("TemplateActive")
	var template_static = grid_container.get_node("TemplateStatic")
	var template_completed = grid_container.get_node("TemplateCompleted")
	
	for contract: ContractBase in ContentManager.contracts.values():
		var use_template
		
		if contract.id == PlayerManager.active_contract.id:
			use_template = template_active
		else:
			use_template = template_static
		
		var clone = use_template.duplicate(true)
		grid_container.add_child(clone)
		
		clone.name = str(contract.id)
		clone.set_meta("ContractBase", contract)
		clone.visible = true
		
		clone.get_node("ContractName").text = "%s\n[color=#facc15]%s"  % [contract.display_name.to_upper(), contract.difficulty.to_upper()]
		clone.get_node("Reward").text = "[color=#94a3b8]UNLOCKS:[/color] [color=#e2e8f0]%s" % contract.reward
		
		if contract.icon:
			clone.get_node("Icon").texture = contract.icon
	
		clone.get_node("ProgressBar").max_value = contract.subtasks.size()
			
		if use_template == template_active:
			clone.get_node("ProgressLabel").text = "%d / %d TASKS" % [PlayerManager.get_total_completed_tasks(), contract.subtasks.size()]
			clone.get_node("ProgressBar").value = PlayerManager.get_total_completed_tasks()
		elif use_template == template_static:
			clone.get_node("ProgressLabel").text = "%d TASKS" % contract.subtasks.size()
			clone.get_node("ProgressBar").value = 0
		
		clone.pressed.connect(_on_contract_btn_pressed.bind(clone))
	
	if PlayerManager.active_contract.base:
		_update_inspector(PlayerManager.active_contract.base)
	else:
		_update_inspector(grid_container.get_children()[3].get_meta("ContractBase"))

func _update_inspector_subtasks(contract: ContractBase, active: bool):
	var subtask_holder: VBoxContainer = selected_contract.get_node("SubtasksHolder")
	var template_complete: Panel = subtask_holder.get_node("TemplateComplete")
	var template_incomplete: Panel = subtask_holder.get_node("TemplateIncomplete")
	
	var active_contract_progress = PlayerManager.active_contract.progress
	
	for child in subtask_holder.get_children():
		if child == template_complete: continue
		if child == template_incomplete: continue
		
		child.queue_free()
		
	for subtask in contract.subtasks:
		var template: Panel = template_incomplete
		var task_index = contract.subtasks.find(subtask)
		
		if active:
			var task_progress = active_contract_progress[task_index]
			
			if task_progress.completed:
				template = template_complete

		var clone = template.duplicate(true)
		
		subtask_holder.add_child(clone)
		clone.visible = true
		clone.get_node("Label").text = "[color=%s]TASK %d -- %s[/color]\n[color=#cbd5e1]%s" % [
			"#94a3b8" if template == template_incomplete else "6ee7b7",
			task_index,
			"INCOMPLETE" if template == template_incomplete else "COMPLETED",
			subtask.cosmetic_text
		]

func _update_inspector(contract: ContractBase):
	selected_contract.get_node("ContractName").text = contract.display_name.to_upper()
	selected_contract.get_node("Difficulty").text = "DIFFICULTY: [color=#facc15]%s" % contract.difficulty
	selected_contract.get_node("Description").text = contract.description
	selected_contract.get_node("Reward").get_node("Primary").text = contract.reward
	
	if contract.icon:
		selected_contract.get_node("Icon").texture = contract.icon
	
	if contract == PlayerManager.active_contract.base:
		selected_contract.get_node("ActivateButton").disabled = true
		selected_contract.get_node("ActivateButton").text = "ACTIVE"
		selected_contract.get_node("StatusBadge").visible = true
		selected_contract.get_node("SubtasksHeader").text = "[color=#c084fc]SUBTASKS[/color] [color=#94a3b8](%d/%d COMPLETED)[/color]" % [PlayerManager.get_total_completed_tasks(), contract.subtasks.size()]
		
		_update_inspector_subtasks(contract, true)
	else:
		selected_contract.get_node("ActivateButton").disabled = false
		selected_contract.get_node("ActivateButton").text = "ACTIVATE CONTRACT"
		selected_contract.get_node("StatusBadge").visible = false
		selected_contract.get_node("SubtasksHeader").text = "[color=#c084fc]SUBTASKS[/color] [color=#94a3b8](0/%d COMPLETED)[/color]" % contract.subtasks.size()
	
		_update_inspector_subtasks(contract, false)

func _update_existing_btns():
	# TEMP
	# This would be change so each template is it's own scene
	# that we just toggle between states.
	
	var template_active = grid_container.get_node("TemplateActive")
	var template_static = grid_container.get_node("TemplateStatic")
	var template_completed = grid_container.get_node("TemplateCompleted")
	
	for child in grid_container.get_children():
		if child == template_active: continue
		if child == template_static: continue
		if child == template_completed: continue	
		
		child.queue_free()
		
	_create_btns()

func _on_contract_btn_pressed(btn: Button):
	_update_inspector(btn.get_meta("ContractBase"))
	chosen_contract = btn.get_meta("ContractBase")

func _on_activate_btn_pressed() -> void:
	PlayerManager.set_contract_active(chosen_contract)
	_update_inspector(chosen_contract)
	_set_inital()
	_update_existing_btns()
