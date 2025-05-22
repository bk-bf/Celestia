## Map generator class responsible for terrain generation and rendering.
## Handles procedural generation of terrain, resources, and territories
## using noise-based algorithms and configurable parameters.
##
## Properties:
## - map_length: Width of the map in cells
## - map_height: Height of the map in cells
## - base_seed: Seed for procedural generation
## - cell_size: Size of each map cell in pixels
##
## Signals:
## - terrain_generated: Emitted when terrain generation is complete

class_name MapGenerator
extends Node2D

# Imports
const MapStatisticsFile = preload("res://src/core/utils/map_statistics.gd")
const ResourceDB = preload("res://src/world/terrain/resource_database.gd")
const MapDataFile = preload("res://src/world/terrain/map_data.gd")
const MapRendererFile = preload("res://src/core/utils/map_renderer.gd")

# Variables for core systems
var map_data: MapData # Stores the map's data structure
var map_renderer: MapRenderer # Handles rendering of the map
var terrain_database: TerrainDatabase # Database for terrain types and properties
var territory_database = TerritoryDatabase.new() # Database for territory definitions
var resource_db = ResourceDB.new() # Database for resource definitions

# Constants for procedural generation
const PRIME_DETAIL_MULTIPLIER: int = 6971
const PRIME_TERRITORY_MULTIPLIER: int = 7919
const DEFAULT_CELL_SIZE: Vector2 = Vector2(32, 32)
const DEFAULT_ZOOM_THRESHOLD: float = 1.5

# Enum for visibility options in the map renderer
enum VisibilityOption {
    GRID_LINES,
    COORDINATE_NUMBERS,
    TERRAIN_LETTERS,
    DENSITY_VALUES,
    MOVEMENT_COSTS,
    RESOURCES
}

# Exported variables for configuration
@export var map_lengh: int = 0 # Width of the map in cells
@export var map_height: int = 0 # Height of the map in cells
@export var show_grid_lines: bool = true
@export var show_coordinate_numbers: bool = true
@export var show_terrain_letters: bool = true
@export var show_territory_markers: bool = true
@export var show_density_values: bool = true
@export var show_movement_costs: bool = true
@export var show_resources: bool = true

@export var cell_size: Vector2 = Vector2(16, 16) # Size of each map cell in pixels
@export var base_seed: int = 0 # Seed for procedural generation (0 = random seed)

# Internal variables for seeds
var detail_seed: int = 0 # Derived seed for terrain details
var territory_seed: int = 0 # Derived seed for territories

# Camera and tilemap references
@onready var camera = $Camera2D
@onready var terrain_tilemap = $TerrainTileMap
@onready var subterrain_tilemap = $SubTerrainTileMap

# Display configuration
var display_config: MapDisplayConfig
var zoom_threshold = DEFAULT_ZOOM_THRESHOLD

# Signal emitted when terrain generation is complete
signal terrain_generated

# Called when the node is added to the scene
func _ready() -> void:
    initialize_core_systems()
    setup_map_statistics()
    setup_map_renderer()
    configure_display_settings()

# Initializes core systems like databases, seeds, and map data
func initialize_core_systems() -> void:
    initialize_databases()
    setup_seeds()
    initialize_map()
    save_map_data()

    # Set the map data in the global manager
    DatabaseManager.map_data = map_data
    DatabaseManager.save_map()

# Sets up map statistics and prints them
func setup_map_statistics() -> void:
    MapStatistics.print_map_statistics(
        map_data,
        terrain_database,
        resource_db,
        base_seed,
        detail_seed,
        territory_seed
    )

    var map_stats = MapStatistics.new()
    map_stats.map_data = map_data
    map_stats.base_seed = base_seed
    map_stats.detail_seed = detail_seed
    # TODO: Fix error 7 in save_statistics_to_file()
    # map_stats.save_statistics_to_file()

# Sets up the map renderer with the required dependencies
func setup_map_renderer() -> void:
    map_renderer = MapRenderer.new(
        map_data,
        terrain_database,
        territory_database,
        $Pathfinder,
        resource_db,
        cell_size,
        camera,
        $"../InputHandler"
    )

    map_renderer.initialize(
        map_data,
        terrain_tilemap,
        subterrain_tilemap
    )

# Configures display settings for the map renderer
func configure_display_settings() -> void:
    display_config = DatabaseManager.display_config

    # Configure initial renderer settings
    if map_renderer:
        map_renderer.show_grid_lines = show_grid_lines
        map_renderer.show_coordinate_numbers = show_coordinate_numbers
        map_renderer.show_density_values = show_density_values
        map_renderer.show_movement_costs = show_movement_costs
        map_renderer.show_terrain_letters = show_terrain_letters
        map_renderer.show_resources = show_resources

    sync_renderer_settings()

# Initializes terrain and resource databases
func initialize_databases() -> void:
    if not terrain_database:
        terrain_database = TerrainDatabase.new()
        if not terrain_database:
            push_error("Failed to initialize terrain database")
            return

    if not resource_db:
        resource_db = ResourceDB.new()
        if not resource_db:
            push_error("Failed to initialize resource database")
            return

# Sets up seeds for procedural generation
func setup_seeds() -> void:
    if base_seed == 0:
        base_seed = randi() # Generate a random seed if none is provided
    detail_seed = base_seed * PRIME_DETAIL_MULTIPLIER
    territory_seed = base_seed * PRIME_TERRITORY_MULTIPLIER

# Initializes the map data and generates terrain
func initialize_map() -> void:
    if map_lengh <= 0 or map_height <= 0:
        push_error("Invalid map dimensions: length=%d, height=%d" % [map_lengh, map_height])
        return

    map_data = MapData.new(Vector2i(map_lengh, map_height), randi())
    generate_terrain(base_seed, detail_seed)
    render_terrain_to_tilemaps(terrain_tilemap, subterrain_tilemap)

# Save map data to the database manager
func save_map_data() -> void:
    DatabaseManager.map_data = map_data
    DatabaseManager.save_map()

# Synchronizes renderer settings with the display configuration
func sync_renderer_settings() -> void:
    if map_renderer:
        map_renderer.show_grid_lines = show_grid_lines
        map_renderer.show_coordinate_numbers = show_coordinate_numbers
        map_renderer.show_terrain_letters = show_terrain_letters
        map_renderer.show_density_values = show_density_values
        map_renderer.show_movement_costs = show_movement_costs
        map_renderer.show_resources = show_resources

# Generates the terrain using noise-based algorithms
func generate_terrain(terrain_seed: int = null, detailed_seed: int = null) -> void:
    initialize_seeds(terrain_seed, detailed_seed)
    var noise_gen = create_noise_generator()
    generate_base_terrain(noise_gen)
    generate_territories()
    generate_resources(noise_gen)
    emit_signal("terrain_generated")

# Initializes seeds for terrain generation
func initialize_seeds(terrain_seed: int, detailed_seed: int) -> void:
    self.terrain_seed = terrain_seed if terrain_seed != null else randi()
    self.detailed_seed = detailed_seed if detailed_seed != null else randi()

# Creates a noise generator for procedural generation
func create_noise_generator() -> NoiseGenerator:
    return NoiseGenerator.new(base_seed, detail_seed)

# Generates the base terrain using noise values
func generate_base_terrain(noise_gen: NoiseGenerator) -> void:
    for y in range(map_data.get_height()):
        for x in range(map_data.get_width()):
            var grid_coords = Vector2i(x, y)
            generate_tile(grid_coords, noise_gen)

# Generates a single tile's properties based on noise values
func generate_tile(coords: Vector2i, noise_gen: NoiseGenerator) -> void:
    var tile = map_data.get_tile(coords)
    var terrain_val = noise_gen.get_terrain_noise(coords.x, coords.y)
    var detail_val = noise_gen.get_detail_noise(coords.x, coords.y)

    set_tile_properties(tile, terrain_val, detail_val)

# Sets the properties of a tile (e.g., terrain type, walkability)
func set_tile_properties(tile: Tile, terrain_val: float, detail_val: float) -> void:
    # Set basic properties
    tile.density = normalize_density(terrain_val)
    tile.terrain_type = terrain_database.get_terrain_type(tile.density)

    # Set water properties
    set_water_properties(tile)

    # Set terrain subtype and walkability
    tile.terrain_subtype = terrain_database.get_subterrain(tile.terrain_type, detail_val)
    tile.walkable = terrain_database.is_walkable(tile.terrain_type, tile.terrain_subtype)

# Normalizes terrain density values to a range of 0 to 1
func normalize_density(terrain_val: float) -> float:
    return (terrain_val + 1.0) / 2.0

# Sets water-related properties for a tile
func set_water_properties(tile: Tile) -> void:
    if tile.terrain_type in terrain_database.terrain_definitions:
        var terrain_def = terrain_database.terrain_definitions[tile.terrain_type]
        if "is_water" in terrain_def:
            tile.set_water(terrain_def.is_water)

# Generates territories on the map
func generate_territories() -> void:
    map_data.register_monster_territories()
    # map_data.post_process_territories()

# Generates resources on the map using a resource generator
func generate_resources(noise_gen: NoiseGenerator) -> void:
    var resource_gen = ResourceGenerator.new(
        map_data,
        resource_db,
        noise_gen,
        base_seed
    )
    resource_gen.generate_resources()

# Renders the terrain to the tilemaps
func render_terrain_to_tilemaps(terrain_tilemap: TileMap, subterrain_tilemap: TileMap) -> void:
    if not terrain_tilemap or not subterrain_tilemap:
        push_error("Invalid tilemaps provided to render_terrain_to_tilemaps")
        return

    if not map_data:
        push_error("No map data available for rendering")
        return

    # Loop through the map data and set tiles
    for y in range(map_data.get_height()):
        for x in range(map_data.get_width()):
            var grid_coords = Vector2i(x, y)
            var tile = map_data.get_tile(grid_coords)

            # Place terrain tile
            var terrain_data = terrain_database.get_terrain_tile_id(tile.terrain_type)
            terrain_tilemap.set_cell(Vector2i(x, y), terrain_data.source_id, Vector2i(terrain_data.coords, 0))

            # Place subterrain tile if applicable
            if tile.terrain_subtype != "":
                var subterrain_data = terrain_database.get_subterrain_tile_id(tile.terrain_subtype)
                subterrain_tilemap.set_cell(Vector2i(x, y), subterrain_data.source_id, Vector2i(subterrain_data.coords, 0))

# Helper function to expose the grid
func get_grid() -> Array:
    return map_data.terrain_grid

# Checks if a noise value falls within a specific territory's thresholds
func is_in_territory(noise_value: float, territory_type: String) -> bool:
    var thresholds = territory_database.get_territory_thresholds(territory_type)
    return noise_value >= thresholds[0] and noise_value < thresholds[1]

# Toggles visibility options for the map renderer
func toggle_visibility(option: VisibilityOption) -> void:
    if not map_renderer:
        return

    match option:
        VisibilityOption.GRID_LINES:
            show_grid_lines = !show_grid_lines
            map_renderer.show_grid_lines = show_grid_lines
        VisibilityOption.COORDINATE_NUMBERS:
            show_coordinate_numbers = !show_coordinate_numbers
            map_renderer.show_coordinate_numbers = show_coordinate_numbers
        VisibilityOption.TERRAIN_LETTERS:
            show_terrain_letters = !show_terrain_letters
            map_renderer.show_terrain_letters = show_terrain_letters
        VisibilityOption.DENSITY_VALUES:
            show_density_values = !show_density_values
            map_renderer.show_density_values = show_density_values
        VisibilityOption.MOVEMENT_COSTS:
            show_movement_costs = !show_movement_costs
            map_renderer.show_movement_costs = show_movement_costs
        VisibilityOption.RESOURCES:
            show_resources = !show_resources
            map_renderer.show_resources = show_resources
        _:
            print("Invalid visibility option")
            return

    DatabaseManager.save_display_config()
    sync_renderer_settings()
    queue_redraw()

# For backward compatibility with existing toggle functions
func toggle_grid_lines() -> void:
    toggle_visibility(VisibilityOption.GRID_LINES)

func toggle_coordinate_numbers() -> void:
    toggle_visibility(VisibilityOption.COORDINATE_NUMBERS)

func toggle_terrain_letters() -> void:
    toggle_visibility(VisibilityOption.TERRAIN_LETTERS)

func toggle_density_values() -> void:
    toggle_visibility(VisibilityOption.DENSITY_VALUES)

func toggle_movement_costs() -> void:
    toggle_visibility(VisibilityOption.MOVEMENT_COSTS)

func toggle_resources() -> void:
    toggle_visibility(VisibilityOption.RESOURCES)

# Main drawing function for the map
func _draw() -> void:
    if map_renderer:
        map_renderer.render(self)