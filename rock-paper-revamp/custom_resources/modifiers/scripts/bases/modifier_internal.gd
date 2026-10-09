extends Resource
class_name ModifierInternal

## The number of charges it starts with. This cannot exceed max charges.
@export var starting_charges: int
## The max amount of charges it can have.
@export var max_charges: int

var charges: int = 0

func initalize():
	charges = starting_charges

func add_charge():
	if charges == max_charges: return
	charges += 1
	
func subtract_charge():
	if charges == 0: return
	charges -= 1

func reset_charges():
	charges = 0
