class_name Tile
extends Resource

# Basic terrain properties
@export var terrain_type: String = ""
@export var terrain_subtype: String = ""
@export var density: float = 0.5 # 0-1 range, 0.5 is default ground level
@export var moisture: float = 0.5
@export var temperature: float = 0.5
@export var movement_cost: float = 1.0 # Default normal movement speed
var _is_water: bool = false

# for pathfinding
var g_cost: float = INF # Cost from start to this tile
var h_cost: float = 0 # Estimated cost from this tile to goal
var f_cost: float = INF # Total cost (g_cost + h_cost)
var parent: Tile = null # Previous tile in the optimal path

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

func set_water(is_water_tile: bool) -> void:
	# Store the water state in a private variable
	_is_water = is_water_tile

func get_resource_value(res_name: String) -> float:
	if res_name in resources:
		return resources[res_name]
	return 0.0
	
# Add any tile-specific calculation methods
func is_resource_rich(resource_type: String, threshold: float) -> bool:
	if resource_type in resources:
		return resources[resource_type] >= threshold
	return false
