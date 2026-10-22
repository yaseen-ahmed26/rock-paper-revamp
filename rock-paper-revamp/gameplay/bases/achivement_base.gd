extends DescribedBase
class_name AchivementBase

const SHOW_IF = {
	"unlock_mastery": "mastery_id"
}

@export_group("Achivement Described")
## The cosmetic steps shown on UI for this achivement.
@export var steps: Array[String]

@export_group("General")
## The specific goals, StringName is the ID of the gamemode/computer/modifier etc.
@export var goals: Dictionary[StringName, int]

@export_group("Flags")
## If true, this achivement unlocks a Modifier Mastery when completed. It will be automatically added to the ContentManager.
@export var unlock_mastery: bool = true

@export_group("Advanced")
## The ID of the modifier mastery to award.
@export var mastery_id: int
