extends ModifierEffect
class_name InternalModifierEffect

## Reset charges.
@export var reset_charges: bool = false
## Add 1 charge.
@export var add_charge: bool = false
## Minus 1 charge.
@export var subtract_charge: bool = false

func apply(internal_state: ModifierInternal):
	if reset_charges:
		internal_state.reset_charges()
	elif add_charge:
		internal_state.add_charge()
	elif subtract_charge:
		internal_state.subtract_charge()
