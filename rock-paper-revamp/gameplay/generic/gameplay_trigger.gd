extends Resource
class_name GameplayTrigger

enum Target {
	PLAYER,
	AI
}

enum Operator {
	EQUAL,
	NOT_EQUAL,
	GREATER,
	GREATER_EQUAL,
	LESS,
	LESS_EQUAL
}

func is_met(_game_stats: GameStats):
	return false
