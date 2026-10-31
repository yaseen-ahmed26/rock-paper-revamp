extends DescribedBase
class_name AchievementBase

const SHOW_IF: Dictionary = {
	"trigger_based": ["stat_key", "target_id", "thresholds"],
	"!trigger_based": ["timing", "triggers", "invert"]
}

@export_group("Flags")
## If true, then a custom array of triggers is used to evaluate this achievement. Otherwise, it uses default keys from the SaveManager.
@export var trigger_based: bool = false

@export_group("Advanced")
@export var stat_key: StringName
@export var target_id: StringName
@export var thresholds: Array[int] = []
@export var timing: ModifierBase.ApplyAt = ModifierBase.ApplyAt.ROUND_END
@export var triggers: Array[GameplayTrigger] = []
@export var invert: bool = false

func get_progress(save_data: Dictionary):
	if trigger_based:
		var completed: Array = save_data.get("completed_achievements", [])
		
		return 1 if id in completed else 0

	if stat_key in [&"gamemodes", &"opponents", &"modifiers"]:
		return save_data.get(stat_key, {}).get(target_id, 0)
	
	return save_data.get(stat_key, 0)

func get_current_tier(current_value: int):
	if trigger_based: return 3 if current_value >= 1 else 0

	var tier: int = 0
	
	for t in thresholds:
		if current_value >= t:
			tier += 1
		else:
			break
			
	return tier

func get_active_target(tier: int):
	if trigger_based: return 1
	if thresholds.is_empty(): return 1
	
	if tier >= thresholds.size():
		return thresholds.back()
		
	return thresholds[tier]

func is_completed(save_data: Dictionary):
	var value: int = get_progress(save_data)
	
	if trigger_based: return value >= 1
		
	return get_current_tier(value) >= thresholds.size()

func get_stars_bbcode(tier: int):
	match tier:
		0: return "[color=#64748b]☆ ☆ ☆[/color]"
		1: return "[color=#facc15]★[/color] [color=#64748b]☆ ☆[/color]"
		2: return "[color=#facc15]★ ★[/color] [color=#64748b]☆[/color]"
		3: return "[color=#facc15]★ ★ ★[/color]"
