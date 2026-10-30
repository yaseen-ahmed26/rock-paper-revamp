extends DescribedBase
class_name ContractBase

const SHOW_IF = {
	"rewards_tokens": "token_reward"
}

@export_group("Contract Described")
## The cosmetic difficulty of this contract.
@export var difficulty: String 
## The cosmetic reward of this contract.
@export var reward: String 
## The cosmetic steps shown on UI for this contract.
@export var steps: Array[String]

@export_group("General")
## The specific tasks for this contract.
@export var subtasks: Array[GameplayTrigger]

@export_group("Flags")
## If true, this contract awards Tokens when completed.
@export var rewards_tokens: bool = true

@export_group("Advanced")
## The amount of tokens given when completed.
@export var token_reward: int
