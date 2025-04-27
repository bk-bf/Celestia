class_name Tile
extends Resource

# Basic terrain properties
@export var terrain_type: String = ""
@export var terrain_subtype: String = ""
@export var density: float = 0.5 # 0-1 range, 0.5 is default ground level
@export var moisture: float = 0.5
@export var temperature: float = 0.5
@export var movement_speed: float = 1.0 # Default normal movement speed

# Resource properties
@export var resources: Dictionary = {}
@export var fertility: float = 0.5

# Positional data
@export var x: int = 0
@export var y: int = 0

# Additional properties for game mechanics
@export var walkable: bool = true
@export var territory_owner: String = "" # For monster territory system
@export var magic_influence: Dictionary = {} # For elemental magic system

func _init(coords: Vector2i = Vector2i(0, 0), den: float = 0.5, terrain: String = "plains"):
	x = coords.x
	y = coords.y
	density = den
	terrain_type = terrain

# Helper methods
func get_coordinates() -> Vector2i:
	return Vector2i(x, y)

func is_water() -> bool:
	return density < 0.3 or terrain_type == "ocean" or terrain_type == "lake" or terrain_type == "river"

func get_resource_value(resource_name: String) -> float:
	if resource_name in resources:
		return resources[resource_name]
	return 0.0
