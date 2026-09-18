extends ModifierEffect
class_name ModifyStatEffect

const SHOW_IF_STAT: Dictionary = {
	"randomise": ["min_value", "max_value"]
}

## The method to apply the value
@export var operation: StatChange.Operation
## The name of the stat to change.
@export var stat_name: String
## If True, set minimum and maximum values to randomise the stat change.
@export var randomise: bool = false
## The value to update the score
@export var value: float
## The minimum amount to randomise
@export var min_value: float = 0.0
## The maxmimum amount to randomise
@export var max_value: float = 0.0

func apply(game_stats: GameStats):
	var stat_change: StatChange = StatChange.new()
	
	stat_change.operation = operation
	stat_change.target_stat = stat_name
	
	stat_change.value = value if not randomise else randf_range(min_value, max_value)
	
	game_stats.apply_stat_change(stat_change)
