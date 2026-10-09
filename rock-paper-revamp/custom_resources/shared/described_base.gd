extends Resource
class_name DescribedBase

@export_group("Described")
## A unique ID for this resource. This ID is used for saving (i.e. saving Modifier or Gamemode usage counts).
@export var id: StringName
## The name, shown on UI. This can be different than the ID.
@export var display_name: String
## The description, shown on UI.
@export var description: String
## An optional icon, shown on UI.
@export var icon: Texture
