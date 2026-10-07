extends Resource
class_name ComputerBase

enum ID {
	GAMBLE,
	STATISTICS,
	ALTERNATOR,
	SMART_ONE
}

@export_group("Metadata")
@export var id: ID
@export var display_name: String
@export var description: String
