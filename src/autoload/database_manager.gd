extends Node

# Central database manager that handles all database types
var terrain_database = TerrainDatabase.new()
var territory_database = TerritoryDatabase.new()
var trait_database = TraitDatabase.new()
var name_database = NameDatabase.new()
var resource_database = ResourceDatabase.new()
var map_data = null
var pawn_manager = null
var save_path = "user://map_data.tres"
@onready var entity_tilemap = $Game/Main/Map/EntityTileMap

signal map_data_loaded

func _ready():
	 # Try to load existing map data
    if FileAccess.file_exists(save_path):
        map_data = ResourceLoader.load(save_path)
        print("Loaded existing map data")
    else:
        # Create new map data if none exists
        const MapDataFile = preload("res://src/world/terrain/map_data.gd")
        map_data = MapDataFile.new()

    print("DatabaseManager initialized")
    
    # Try to find PawnManager reference
    if get_node_or_null("/root/Game/Main/PawnManager"):
        pawn_manager = get_node("/root/Game/Main/PawnManager")
    
    # Use call_deferred to ensure map_data is fully initialized
    call_deferred("emit_signal", "map_data_loaded")


func generate_new_map(width, height, seed_value):
    # Create new map data
    const MapDataFile = preload("res://src/world/terrain/map_data.gd")
    map_data = MapDataFile.new()
    
    # Initialize with parameters
    map_data.initialize(width, height, seed_value)
    
    # Save the newly generated map
    save_map()

# TERRAIN DATABASE FUNCTIONS
func get_movement_cost(terrain_type: String) -> float:
    if terrain_database.terrain_definitions.has(terrain_type):
        return terrain_database.terrain_definitions[terrain_type].get("movement_cost", 1.0)
    return 1.0

func is_walkable(terrain_type: String) -> bool:
    if terrain_database.terrain_definitions.has(terrain_type):
        return terrain_database.terrain_definitions[terrain_type].get("walkable", true)
    return true

func get_terrain_color(terrain_type: String) -> Color:
    if terrain_database.terrain_definitions.has(terrain_type):
        return terrain_database.terrain_definitions[terrain_type].get("base_color", Color.WHITE)
    return Color.WHITE

func get_subterrain_definitions() -> Dictionary:
    return terrain_database.subterrain_definitions

func get_terrain_types() -> Array:
    return terrain_database.terrain_definitions.keys()

# TERRITORY DATABASE FUNCTIONS
func get_monster_types():
    return territory_database.get_monster_types()

func get_territory_thresholds(monster_type):
    return territory_database.get_territory_thresholds(monster_type)

# TRAIT DATABASE FUNCTIONS
func get_trait(trait_name):
    return trait_database.get_trait(trait_name)

func get_traits_by_category(category):
    return trait_database.get_traits_by_category(category)

# NAME DATABASE FUNCTIONS
func get_random_name():
    return name_database.get_random_name()

func get_male_name():
    var gender = "male"
    var first_name = name_database.male_first_names[randi() % name_database.male_first_names.size()]
    var surname = name_database.surnames[randi() % name_database.surnames.size()]
    return {
        "name": first_name + " " + surname,
        "gender": gender
    }

func get_female_name():
    var gender = "female"
    var first_name = name_database.female_first_names[randi() % name_database.female_first_names.size()]
    var surname = name_database.surnames[randi() % name_database.surnames.size()]
    return {
        "name": first_name + " " + surname,
        "gender": gender
    }

# RESOURCE DATABASE FUNCTIONS
func get_resource_types():
    return resource_database.resource_definitions.keys()

func get_resource_data(resource_type: String):
    if resource_database.resource_definitions.has(resource_type):
        return resource_database.resource_definitions[resource_type]
    return null

func get_resources_by_category(category: String) -> Array:
    var result = []
    for resource_type in resource_database.resource_definitions.keys():
        var resource = resource_database.resource_definitions[resource_type]
        if resource.has("category") and resource["category"] == category:
            result.append(resource_type)
    return result

# MAP DATA FUNCTIONS
func save_map(custom_path = null):
    var path = custom_path if custom_path else save_path
    if map_data:
        var result = map_data.save_to_file(path)
        print("Map saved with result: " + str(result))
        return result
    return ERR_UNCONFIGURED

# PAWN MANAGER FUNCTIONS
func get_all_pawns():
    if pawn_manager:
        return pawn_manager.get_all_pawns()
    return []

func create_pawn(position):
    if pawn_manager:
        return pawn_manager.create_pawn(position)
    return null
