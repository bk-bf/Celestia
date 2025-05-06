extends Node

# This script makes the TerrainDatabase accessible globally
var terrain_database = TerrainDatabase.new()

func _ready():
    # Initialize any additional setup here
    print("TerrainDatabaseManager initialized")
    
    # You could load custom terrain definitions here if needed
    # load_custom_terrain_definitions()

# Get terrain movement cost
func get_movement_cost(terrain_type: String) -> float:
    if terrain_database.terrain_definitions.has(terrain_type):
        return terrain_database.terrain_definitions[terrain_type].get("movement_cost", 1.0)
    return 1.0

# Check if terrain is walkable
func is_walkable(terrain_type: String) -> bool:
    if terrain_database.terrain_definitions.has(terrain_type):
        return terrain_database.terrain_definitions[terrain_type].get("walkable", true)
    return true

# Get terrain color
func get_terrain_color(terrain_type: String) -> Color:
    if terrain_database.terrain_definitions.has(terrain_type):
        return terrain_database.terrain_definitions[terrain_type].get("base_color", Color.WHITE)
    return Color.WHITE

# Get subterrain definitions
func get_subterrain_definitions() -> Dictionary:
    return terrain_database.subterrain_definitions

# Get all terrain types
func get_terrain_types() -> Array:
    return terrain_database.terrain_definitions.keys()
