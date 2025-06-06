extends Node2D

# Imports
const MapStatisticsFile = preload("res://src/core/utils/map_statistics.gd")
const ResourceDB = preload("res://src/world/terrain/resource_database.gd")
const MapDataFile = preload("res://src/world/terrain/map_data.gd")
const MapRendererFile = preload("res://src/core/utils/map_renderer.gd")

var map_data: MapData
var map_renderer: MapRenderer
var terrain_database: TerrainDatabase # Add territory database
var territory_database = TerritoryDatabase.new() # Add monsters database
var resource_db = ResourceDB.new() # Add resource database

@export var map_lengh: int = 0
@export var map_height: int = 0
@export var show_grid_lines: bool = true
@export var show_coordinate_numbers: bool = true
@export var show_terrain_letters: bool = true
@export var show_territory_markers: bool = true
@export var show_density_values: bool = true
@export var show_movement_costs: bool = true
@export var show_resources: bool = true

@export var cell_size: Vector2 = Vector2(16, 16)
@export var base_seed: int = 0 # If left as 0, a random seed will be used
var detail_seed: int = 0
var territory_seed: int = 0 # Derived seed for territories

@onready var camera = $Camera2D
var zoom_threshold = 1.5

# for TileMap
@onready var terrain_tilemap = $TerrainTileMap
@onready var subterrain_tilemap = $SubTerrainTileMap

# signal from generate_terrain()
signal terrain_generated


func _ready():
	# Initialize terrain database
	terrain_database = TerrainDatabase.new()
	# Check if seeds are 0 and generate random seeds if needed
	if base_seed == 0:
		base_seed = randi()
		
	detail_seed = base_seed * 6971 # multiplied with prime
	territory_seed = base_seed * 7919 # Using different prime multiplier
 	# Create a map with the same dimensions but procedurally generated
	map_data = MapData.new(Vector2i(map_lengh, map_height), randi())
	
	# Generate terrain with stored seeds
	generate_terrain(seed, detail_seed)
	
	# Then render to TileMaps
	render_terrain_to_tilemaps(terrain_tilemap, subterrain_tilemap)

	# Set the map data in the global manager
	DatabaseManager.map_data = map_data
	DatabaseManager.save_map()
	
	# Map Statistics
	MapStatistics.print_map_statistics(map_data, terrain_database, resource_db, base_seed, detail_seed, territory_seed)
	
	# Create an instance of MapStatistics
	var map_stats = MapStatistics.new()
	# Set required properties on the instance
	map_stats.map_data = map_data
	map_stats.base_seed = base_seed
	map_stats.detail_seed = detail_seed
	# Call the save_statistics_to_file method on the instance
	# map_stats.save_statistics_to_file() # this shit fails with error 7 but the directory it safes to exists and is always writeable

	# Initialize the map renderer
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

	# calling the MapRenderer intitializer
	# CAN AT MOST HANDLE 3 ARGUMENTS
	map_renderer.initialize(map_data, terrain_tilemap, subterrain_tilemap)


	# Configure renderer settings
	map_renderer.show_grid_lines = show_grid_lines
	map_renderer.show_coordinate_numbers = show_coordinate_numbers
	map_renderer.show_density_values = show_density_values
	map_renderer.show_movement_costs = show_movement_costs
	map_renderer.show_terrain_letters = show_terrain_letters
	map_renderer.show_resources = show_resources

	# Initial sync of settings
	sync_renderer_settings()
	
	
func sync_renderer_settings():
	if map_renderer:
		map_renderer.show_grid_lines = show_grid_lines
		map_renderer.show_coordinate_numbers = show_coordinate_numbers
		map_renderer.show_terrain_letters = show_terrain_letters
		map_renderer.show_density_values = show_density_values
		map_renderer.show_movement_costs = show_movement_costs
		

# function to generate terrain using noise and TerrainDatabase
func generate_terrain(terrain_seed = null, detailed_seed = null):
	# Use provided seeds or generate new ones
	terrain_seed = terrain_seed if terrain_seed != null else randi()
	detailed_seed = detailed_seed if detailed_seed != null else randi()

	var noise_gen = NoiseGenerator.new(base_seed, detail_seed)

	# First pass: Generate basic terrain types and terrain_subtypes
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var grid_coords = Vector2i(x, y)
			var tile = map_data.get_tile(grid_coords)
			
			# Get noise values
			var terrain_val = noise_gen.get_terrain_noise(x, y)
			var detail_val = noise_gen.get_detail_noise(x, y)
			
			# Set tile density based on noise
			tile.density = (terrain_val + 1.0) / 2.0
			
			# Determine terrain type based on density using TerrainDatabase
			tile.terrain_type = terrain_database.get_terrain_type(tile.density)
			
			# Check if this terrain has is_water property and set it
			if tile.terrain_type in terrain_database.terrain_definitions and "is_water" in terrain_database.terrain_definitions[tile.terrain_type]:
				tile.set_water(terrain_database.terrain_definitions[tile.terrain_type].is_water)
			
			# Set terrain_subtype based on detail noise using TerrainDatabase
			tile.terrain_subtype = terrain_database.get_subterrain(tile.terrain_type, detail_val)
			
			# Set walkable property based on terrain and subterrain
			tile.walkable = terrain_database.is_walkable(tile.terrain_type, tile.terrain_subtype)
	
	map_data.register_monster_territories()
	#map_data.post_process_territories()

	# Add resource generation as a separate step
	var resource_gen = ResourceGenerator.new(map_data, resource_db, noise_gen, base_seed)
	resource_gen.generate_resources()
	
	emit_signal("terrain_generated")

func render_terrain_to_tilemaps(terrain_tilemap, subterrain_tilemap):
	# Loop through your existing map_data and set tiles
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


# helper function to expose the grid
func get_grid():
	return map_data.terrain_grid


# toggle functions - might have to be redone into setters with backing variable? 
func is_in_territory(noise_value, territory_type):
	var thresholds = territory_database.get_territory_thresholds(territory_type)
	return noise_value >= thresholds[0] and noise_value < thresholds[1]

func toggle_grid_lines():
	show_grid_lines = !show_grid_lines
	if map_renderer:
		map_renderer.show_grid_lines = show_grid_lines
		queue_redraw()

func toggle_coordinate_numbers():
	show_coordinate_numbers = !show_coordinate_numbers
	if map_renderer:
		map_renderer.show_coordinate_numbers = show_coordinate_numbers
		queue_redraw()

func toggle_terrain_letters():
	show_terrain_letters = !show_terrain_letters
	if map_renderer:
		map_renderer.show_terrain_letters = show_terrain_letters
		queue_redraw()

func toggle_density_values():
	show_density_values = !show_density_values
	if map_renderer:
		map_renderer.show_density_values = show_density_values
		queue_redraw()

func toggle_movement_costs():
	show_movement_costs = !show_movement_costs
	if map_renderer:
		map_renderer.show_movement_costs = show_movement_costs
		queue_redraw()

func toggle_resources():
	show_resources = !show_resources
	if map_renderer:
		map_renderer.show_resources = show_resources
		queue_redraw()


# Main drawing function 
func _draw():
	if map_renderer:
		map_renderer.render(self)
