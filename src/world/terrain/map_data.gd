class_name MapData
extends Resource

# Core terrain grid
@export var terrain_grid: Grid

# Map properties
@export var map_seed: int = 0
@export var map_name: String = "Celestia Map"
@export var map_size: Vector2i = Vector2i(200, 200)

# Biome distribution
var biome_distribution: Dictionary = {}

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

func get_biome_percentage(biome_type: String) -> float:
	var count = 0
	var total = get_width() * get_height()
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if tile.biome_type == biome_type:
				count += 1
				
	return float(count) / float(total) if total > 0 else 0.0

# Find tiles matching criteria
func find_tiles_by_biome(biome_type: String) -> Array:
	var matching_tiles = []
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if tile.biome_type == biome_type:
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
					
					
# Convert grid coordinates to world position
func grid_to_world(grid_coords: Vector2i) -> Vector2:
	return terrain_grid.grid_to_world(grid_coords)

# Convert world position to grid coordinates
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return terrain_grid.world_to_grid(world_pos)

# Check if world coordinates are within map bounds
func is_within_bounds_world(world_pos: Vector2) -> bool:
	var grid_coords = world_to_grid(world_pos)
	return terrain_grid.is_valid_coordinates(grid_coords)
