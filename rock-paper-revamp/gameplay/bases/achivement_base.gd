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
