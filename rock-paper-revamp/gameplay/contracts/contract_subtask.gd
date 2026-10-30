extends Resource
class_name ContractSubtask

## The Triggers needed for this task.
@export var triggers: Array[GameplayTrigger]
## The cosmetic text to display on UI.
@export var cosmetic_text: String
## If true, then all Triggers MUST evaluate to false to be considered complete.
@export var invert: bool = false
## How many times this subtask needs to be completed to considered true. Set to 1 for only 1 time needed to be completed.
@export var completion_amount: int = 1
