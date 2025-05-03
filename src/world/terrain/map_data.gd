class_name MapData
extends Resource

var territory_database = TerritoryDatabase.new() # Add monsters database
var noise_generator = NoiseGenerator.new()
var terrain_database = TerrainDatabase.new()
# Core terrain grid
@export var terrain_grid: Grid

# Map properties
@export var map_seed: int = 0
@export var map_name: String = "Celestia Map"
@export var map_size: Vector2i = Vector2i(200, 200)

# terrain distribution
var terrain_distribution: Dictionary = {}

# Resource maps
var resource_maps: Dictionary = {}

# Territory data for monster system
var monster_territories: Array = []

# Water bodies
var rivers: Array = []
var lakes: Array = []
var ocean_tiles: Array = []

# for tile_data.gd
var tile_data = TileData.new()

# Initialization
func _init(size: Vector2i = Vector2i(200, 200), set_seed: int = 0):
	map_size = size
	map_seed = set_seed
	terrain_grid = Grid.new(size.x, size.y)
	
# Save and load functionality
func save_to_file(path: String) -> Error:
	return ResourceSaver.save(self, path)
	
static func load_from_file(path: String) -> MapData:
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path) as MapData
	return null

# Getters and setters
func get_tile(coords: Vector2i) -> Tile:
	return terrain_grid.get_tile(coords)
	
func set_tile(coords: Vector2i, tile: Tile) -> void:
	terrain_grid.set_tile(coords, tile)
	
func get_width() -> int:
	return map_size.x
	
func get_height() -> int:
	return map_size.y

# Utility methods for terrain analysis
func get_average_density() -> float:
	var sum = 0.0
	var count = 0
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			sum += tile.density
			count += 1
			
	return sum / count if count > 0 else 0.5 # Default to normal ground density

func get_random_center_position() -> Vector2i:
	# Calculate the center of the map
	var center_x = get_width() / 2
	var center_y = get_height() / 2
	
	# Define the 10x10 area (5 tiles in each direction from center)
	var start_x = center_x - 5
	var start_y = center_y - 5
	
	# Try a limited number of times to find a valid position
	for _attempt in range(10):
		# Generate random position within this area
		var random_x = start_x + randi() % 10
		var random_y = start_y + randi() % 10
		
		# Make sure the position is valid and walkable
		var position = Vector2i(random_x, random_y)
		if is_within_bounds_map(Vector2(position.x, position.y)):
			var tile = get_tile(position)
			if tile.walkable:
				return position
	
	# If no valid position found after attempts, fall back to the center
	return Vector2i(center_x, center_y)

func get_walkable_percentage() -> float:
	var count = 0
	var total = get_width() * get_height()
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if tile.walkable:
				count += 1
	
	return float(count) / total

func get_terrain_percentage(terrain_type: String) -> float:
	var count = 0
	var total = get_width() * get_height()
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if tile.terrain_type == terrain_type:
				count += 1
				
	return float(count) / float(total) if total > 0 else 0.0

# Find tiles matching criteria
func find_tiles_by_terrain(terrain_type: String) -> Array:
	var matching_tiles = []
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if tile.terrain_type == terrain_type:
				matching_tiles.append(tile)
				
	return matching_tiles

func find_tiles_by_density_range(min_density: float, max_density: float) -> Array:
	var matching_tiles = []
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if tile.density >= min_density and tile.density <= max_density:
				matching_tiles.append(tile)
				
	return matching_tiles

# For monster territory system
func register_monster_territory(seed_value: int, territory_type: String, territory_thresholds: Array = [0.4, 0.6]) -> void:
	# Record territory in list with thresholds
	monster_territories.append({
		"seed": seed_value,
		"monster_type": territory_type,
		"thresholds": territory_thresholds
	})
	
	# Get preferred terrain for this monster type
	#var preferred_terrain = territory_database.get_monster_data(territory_type).preferred_terrain
	
	 # Get preferred terrain for this monster type
	# var preferred_terrain = territory_database.get_monster_data(territory_type).preferred_terrain
	
	# Assign territory based on terrain noise
	for y in range(get_height()):
		for x in range(get_width()):
			# Use existing terrain noise but normalize it
			var raw_noise_val = noise_generator.get_terrain_noise(x, y)
			var territory_density = (raw_noise_val + 1.0)
			#print(territory_density)
			
			# Territory is where density is within thresholds
			if territory_density >= territory_thresholds[0] and territory_density < territory_thresholds[1]:
				var tile = get_tile(Vector2i(x, y))
				
				# Simple territory assignment with more lenient conditions
				# Only avoid water/river
				if tile.terrain_type != "river" and tile.terrain_type != "water":
					#print("Tile object ID: " + str(tile.get_instance_id()) + " Tile terrain: '" + tile.terrain_type + ", Grid Coords: (" + str(x) + ", " + str(y) + ")")
					tile.territory_owner = territory_type

var cleanup_count = 0 # outside of function to be accessible by statisctics.gd print

func post_process_territories(): # Clean up each territory type
	for territory_type in territory_database.get_monster_types():
		var preferred_terrains = territory_database.get_monster_data(territory_type).preferred_terrain
		
		# Check all tiles
		for y in range(get_height()):
			for x in range(get_width()):
				var tile = get_tile(Vector2i(x, y))
				
				# If this tile has this territory but wrong terrain, remove it
				if tile.territory_owner == territory_type and not (tile.terrain_type in preferred_terrains):
					#print("Tile terrain: '" + tile.terrain_type + "', Preferred: " + str(preferred_terrains) + ", Grid Coords: (" + str(x) + ", " + str(y) + ")")
					tile.territory_owner = ""
					cleanup_count += 1

func count_territories_by_type(monster_type: String) -> int:
	var count = 0
	for territory in monster_territories:
		if territory["monster_type"] == monster_type:
			count += 1
	return count
		
func get_territory_coverage() -> float:
	var territory_count = 0
	var total = get_width() * get_height()
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if tile.territory_owner != "":
				territory_count += 1
	
	return float(territory_count) / total if total > 0 else 0.0
	
# Convert grid coordinates to map position
func grid_to_map(grid_coords: Vector2i) -> Vector2:
	return terrain_grid.grid_to_map(grid_coords)

# Convert map position to grid coordinates
func map_to_grid(map_pos: Vector2) -> Vector2i:
	return terrain_grid.map_to_grid(map_pos)

# Check if map coordinates are within map bounds
func is_within_bounds_map(map_pos: Vector2) -> bool:
	var grid_coords = map_to_grid(map_pos)
	return terrain_grid.is_valid_coordinates(grid_coords)
	

func generate_terrain(width: int, height: int):
	var noise_gen = NoiseGenerator.new()
	
	# First pass: Generate basic terrain types for all tiles
	for y in range(height):
		for x in range(width):
			var grid_coords = Vector2i(x, y)
			
			# Get base terrain density value
			var density = noise_gen.get_terrain_noise(x, y)
			
			# Create tile with basic terrain type
			var tile = Tile.new()
			tile.density = (density + 1.0) / 2.0 # Normalize to 0-1 range
			tile.terrain_type = determine_terrain_type(density)
			
			# Set water status
			tile.set_water(tile.terrain_type == "water")
			
			set_tile(grid_coords, tile)
	
	# Second pass: Apply detail terrain_subtypes and water proximity effects
	for y in range(height):
		for x in range(width):
			var grid_coords = Vector2i(x, y)
			var tile = get_tile(grid_coords)
			var detail_val = noise_gen.get_detail_noise(x, y)
			
			# Calculate proximity to water for terrain blending
			var water_proximity = 0.0
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var check_pos = Vector2i(x + dx, y + dy)
					if is_within_bounds_map(check_pos):
						var neighbor = get_tile(check_pos)
						if neighbor.is_water():
							water_proximity += 0.1
			
			# Apply special handling for water borders
			if water_proximity > 0 && !tile.is_water():
				if tile.terrain_type == "mountain":
					# Mountains near water become rocky cliffs
					tile.terrain_subtype = "rocky_cliff"
				elif tile.terrain_type == "forest":
					# Forests near water become sparse
					tile.terrain_subtype = "sparse_trees"
				else:
					# For other terrain types, apply normal terrain_subtypes
					tile.terrain_subtype = determine_terrain_subtype(tile.terrain_type, detail_val)
			else:
				# Normal terrain_subtype assignment for tiles not near water
				tile.terrain_subtype = determine_terrain_subtype(tile.terrain_type, detail_val)


func determine_terrain_type(density: float) -> String:
	return tile_data.get_terrain_type(density)

func determine_terrain_subtype(terrain_type: String, detail_val: float) -> String:
	var terrain_subtype = tile_data.terrain_definitions[terrain_type].variations
	
	# Select terrain subtype based on detail_val
	var normalized_detail = (detail_val + 1.0) / 2.0 # Convert from -1,1 to 0,1
	var index = floor(normalized_detail * terrain_subtype.size())
	index = clamp(index, 0, terrain_subtype.size() - 1)
	
	return terrain_subtype[index]
	
func get_subterrain_percentage(subterrain_type: String) -> float:
	var count = 0
	var total = 0
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			total += 1
			if tile.terrain_subtype == subterrain_type:
				count += 1
	
	return float(count) / total if total > 0 else 0.0
