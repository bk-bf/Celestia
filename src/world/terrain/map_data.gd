class_name MapData
extends Resource

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

# Initialization
func _init(size: Vector2i = Vector2i(200, 200), set_seed : int = 0):
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

func find_tiles_with_resource(resource_name: String, min_value: float = 0.0) -> Array:
	var matching_tiles = []
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if tile.get_resource_value(resource_name) >= min_value:
				matching_tiles.append(tile)
				
	return matching_tiles

# For monster territory system
func register_monster_territory(center: Vector2i, radius: float, monster_type: String) -> void:
	monster_territories.append({
		"center": center,
		"radius": radius,
		"monster_type": monster_type
	})
	
	# Mark tiles as belonging to this territory
	for y in range(get_height()):
		for x in range(get_width()):
			var coords = Vector2i(x, y)
			var distance = coords.distance_to(center)
			if distance <= radius:
				var tile = get_tile(coords)
				if tile:
					tile.territory_owner = monster_type
					
					
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
	
# In your MapData or similar class
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
			tile.density = (density + 1.0) / 2.0  # Normalize to 0-1 range
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
	if density < -0.5:
		return "water"
	elif density < -0.2:
		return "swamp"
	elif density < 0.2:
		return "plains"
	elif density < 0.6:
		return "forest"
	else:
		return "mountain"

func determine_terrain_subtype(terrain_type: String, detail_val: float) -> String:
	match terrain_type:
		"forest":
			if detail_val < -0.6:
				return "dirt"
			elif detail_val < -0.2:
				return "grass"
			elif detail_val < 0.2:
				return "bush"
			elif detail_val < 0.6:
				return "deep_grass"
			else:
				return "tree"
		"swamp":
			if detail_val < -0.6:
				return "shallow_water"
			elif detail_val < -0.2:
				return "mud"
			elif detail_val < 0.2:
				return "bog"
			elif detail_val < 0.6:
				return "clay"
			else:
				return "moss"
		
				
		# More terrain types and terrain_subtypes...
		
	# return if no match was found
	return "plains"  
