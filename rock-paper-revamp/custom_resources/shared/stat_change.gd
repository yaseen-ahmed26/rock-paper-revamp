extends Resource
class_name StatChange

enum Operation {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE,
	SET
}

@export_category("Properties")
@export var operation: Operation
@export var target_stat: String
@export var value: Variant
