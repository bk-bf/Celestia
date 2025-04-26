class_name WorldData
extends Resource

# Core terrain grid
@export var terrain_grid: Grid

# World properties
@export var world_seed: int = 0
@export var world_name: String = "Celestia World"
@export var world_size: Vector2i = Vector2i(200, 200)

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
func _init(size: Vector2i = Vector2i(200, 200), seed_value: int = 0):
	world_size = size
	world_seed = seed_value
	terrain_grid = Grid.new(size.x, size.y)
	
# Save and load functionality
func save_to_file(path: String) -> Error:
	return ResourceSaver.save(self, path)
	
static func load_from_file(path: String) -> WorldData:
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path) as WorldData
	return null

# Getters and setters
func get_tile(coords: Vector2i) -> Tile:
	return terrain_grid.get_tile(coords)
	
func set_tile(coords: Vector2i, tile: Tile) -> void:
	terrain_grid.set_tile(coords, tile)
	
func get_width() -> int:
	return world_size.x
	
func get_height() -> int:
	return world_size.y

# Utility methods for terrain analysis
func get_average_altitude() -> float:
	var sum = 0.0
	var count = 0
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			sum += tile.altitude
			count += 1
			
	return sum / count if count > 0 else 0.0

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

func find_tiles_by_altitude_range(min_alt: float, max_alt: float) -> Array:
	var matching_tiles = []
	
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if tile.altitude >= min_alt and tile.altitude <= max_alt:
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
