class_name Tile
extends Resource

# Basic terrain properties
@export var altitude: float = 0.0
@export var biome_type: String = "plains"
@export var moisture: float = 0.5
@export var temperature: float = 0.5

# Resource properties
@export var resources: Dictionary = {}
@export var fertility: float = 0.5

# Positional data
@export var x: int = 0
@export var y: int = 0

# Additional properties for game mechanics
@export var walkable: bool = true
@export var territory_owner: String = ""  # For monster territory system
@export var magic_influence: Dictionary = {}  # For elemental magic system

func _init(coords: Vector2i = Vector2i(0, 0), alt: float = 0.0, biome: String = "plains"):
	x = coords.x
	y = coords.y
	altitude = alt
	biome_type = biome

# Helper methods
func get_coordinates() -> Vector2i:
	return Vector2i(x, y)

func is_water() -> bool:
	return altitude < 0.0 or biome_type == "ocean" or biome_type == "lake" or biome_type == "river"

func get_resource_value(resource_name: String) -> float:
	if resource_name in resources:
		return resources[resource_name]
	return 0.0
