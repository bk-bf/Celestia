class_name MapData
extends Resource

var territory_database = DatabaseManager.territory_database
var terrain_database = DatabaseManager.terrain_database
var pathfinder = Pathfinder
# Core terrain grid
@export var terrain_grid: Grid

# Map properties
@export var map_seed: int = 0
@export var map_name: String = "Celestia Map"
@export var map_size: Vector2i = Vector2i(200, 200)
@export var max_territoy_size: int = 700
@export var max_territory_count: int = 200
@export var min_territory_count: int = 100
@export var territory_coverage_percentage: float = 0.8

# terrain distribution
var terrain_distribution: Dictionary = {}

# Resource maps
var resource_maps: Dictionary = {}
signal tile_resource_changed(position)

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
	pathfinder = Pathfinder.new(terrain_grid) # Create an instance
	
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

func get_resources_at(position: Vector2i):
	var tile = get_tile(position)
	if tile and "resources" in tile:
		return tile.resources
	return null

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
func register_monster_territories() -> void:
	# First, group territories by preferred terrain
	var territories_by_terrain = {}
	
	# Organize monsters by their preferred terrain
	for territory_type in territory_database.territory_definitions.keys():
		var preferred_terrains = territory_database.territory_definitions[territory_type]["preferred_terrain"]
		for terrain in preferred_terrains:
			if not territories_by_terrain.has(terrain):
				territories_by_terrain[terrain] = []
			territories_by_terrain[terrain].append(territory_type)
	
	# For each terrain type, find suitable tiles and assign territories
	for terrain_type in territories_by_terrain.keys():
		var suitable_tiles = []
		
		# Find all tiles of this terrain type
		for y in range(get_height()):
			for x in range(get_width()):
				var tile = get_tile(Vector2i(x, y))
				if tile.terrain_type == terrain_type:
					suitable_tiles.append(Vector2i(x, y))
		
		# Skip if no suitable tiles
		if suitable_tiles.size() == 0:
			continue
			
		# Get monsters that prefer this terrain
		var possible_monsters = territories_by_terrain[terrain_type]
		
		# Apply rarity filter - rare monsters have lower chance of being selected
		var weighted_monsters = []
		for monster_type in possible_monsters:
			var rarity = territory_database.territory_definitions[monster_type]["rarity"]
			# Add the monster to the selection pool 'rarity' number of times
			for i in range(rarity):
				weighted_monsters.append(monster_type)
		
		# Determine how many territories to create for this terrain
		var territory_count = int(suitable_tiles.size() * territory_coverage_percentage)
		territory_count = max(min_territory_count, min(territory_count, max_territory_count))
		
		# Assign territories
		for i in range(territory_count):
			# Pick a random monster type with rarity weighting
			var monster_type = weighted_monsters[randi() % weighted_monsters.size()]
			
			# Create a territory seed point
			var seed_point = suitable_tiles[randi() % suitable_tiles.size()]
			
			# Expand territory from seed point
			expand_territory_from_seed(seed_point, monster_type, terrain_type)

###OMG PLEASE END IT THAT IS INSANE AND SHOULD BE ILLEGAL
func expand_territory_from_seed(seed_point: Vector2i, monster_type: String, terrain_type: String, max_size: int = max_territoy_size) -> void:
	# Create a queue for flood fill algorithm
	var queue = []
	queue.push_back(seed_point)
	
	# Keep track of tiles we've already processed
	var processed_tiles = {}
	processed_tiles[Vector2i(seed_point.x, seed_point.y)] = true
	
	# Keep track of how many tiles we've added to this territory
	var territory_size = 0
	
	# Get territory color for visualization
	var territory_color = territory_database.territory_definitions[monster_type]["color"]
	
	# Process the queue until empty or we reach max size
	while queue.size() > 0 and territory_size < max_size:
		# Get the next tile to process
		var current = queue.pop_front()
		
		# Get the current tile
		var tile = get_tile(current)
		
		# Skip if this tile already has a territory owner with a different coexistence layer
		if "territory_owner" in tile and tile["territory_owner"] != "":
			var current_owner = tile["territory_owner"]
			var current_layer
			var new_layer = territory_database.territory_definitions[monster_type].get("coexistence_layer", null)
			
			# Handle both string and array territory owners
			if typeof(current_owner) == TYPE_STRING:
				# Check if the current owner contains multiple territories
				if "," in current_owner:
					# Split the comma-separated string into individual territory types
					var owners = current_owner.split(",")
					
					# Check if monster_type already exists in the list
					if monster_type in owners:
						continue # Skip if already in the list
						
					# Get the coexistence layer of the first territory
					current_layer = territory_database.territory_definitions[owners[0]]["coexistence_layer"]
					
					if current_layer != new_layer:
						continue # Skip if layers don't match
					else:
						# Add to existing comma-separated list
						tile["territory_owner"] = current_owner + "," + monster_type
						territory_size += 1
				else:
					# Single territory owner
					current_layer = territory_database.territory_definitions[current_owner]["coexistence_layer"]
					
					# Skip if it's the same monster type
					if current_owner == monster_type:
						continue
						
					if current_layer != new_layer:
						continue # Skip if layers don't match
					else:
						# Territories can coexist, store as a list
						tile["territory_owner"] = current_owner + "," + monster_type
						territory_size += 1
			else: # Array of territory owners
				# Get the coexistence layer of the first territory (assuming all have the same layer)
				current_layer = territory_database.territory_definitions[current_owner[0]]["coexistence_layer"]
				
				if current_layer != new_layer:
					continue # Skip if layers don't match
				elif not monster_type in current_owner: # Avoid duplicates
					# Add to existing array
					tile["territory_owner"].append(monster_type)
					territory_size += 1
				else:
					continue # Skip if already in the list

		# Skip if this tile isn't the preferred terrain type
		if tile["terrain_type"] != terrain_type:
			continue
			
		# Skip if this tile isn't walkable (water/river)
		if not tile["walkable"]:
			continue
			
		# Assign territory to this tile
		tile["territory_owner"] = monster_type
		territory_size += 1
		
		# Add neighboring tiles to the queue (8-way connectivity)
		var neighbors = [
			Vector2i(current.x + 1, current.y),
			Vector2i(current.x - 1, current.y),
			Vector2i(current.x, current.y + 1),
			Vector2i(current.x, current.y - 1),
			Vector2i(current.x + 1, current.y + 1),
			Vector2i(current.x - 1, current.y - 1),
			Vector2i(current.x + 1, current.y - 1),
			Vector2i(current.x - 1, current.y + 1)
		]
		
		# Process each neighbor
		for neighbor in neighbors:
			# Skip some tiles for organic look
			if randf() < 0.3:
				continue
			# Skip if out of bounds
			if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= get_width() or neighbor.y >= get_height():
				continue
				
			# Skip if already processed
			if Vector2i(neighbor.x, neighbor.y) in processed_tiles:
				continue
				
			# Mark as processed and add to queue
			processed_tiles[Vector2i(neighbor.x, neighbor.y)] = true
			queue.push_back(neighbor)
	
	# Record territory in list
	monster_territories.append({
		"seed": seed_point,
		"monster_type": monster_type,
		"size": territory_size
	})


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

func get_territory_owners():
	var owners = {}
	
	# Loop through all tiles to count territories
	for y in range(get_height()):
		for x in range(get_width()):
			var tile = get_tile(Vector2i(x, y))
			if "territory_owner" in tile and tile["territory_owner"] != "": # this works to access territories without a specific func in tile
				if not owners.has(tile.territory_owner):
					owners[tile.territory_owner] = 0
				owners[tile.territory_owner] += 1
	
	return owners

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

	
func reduce_resource_at(position: Vector2i, amount: int):
	var tile = get_tile(position)
	if not tile or not "resources" in tile:
		return false

	# Assuming there's only one resource type per tile for simplicity
	var resource_type = tile.resources.keys()[0] if tile.resources.size() > 0 else null

	if not resource_type:
		return false

	# Reduce the resource
	tile.resources[resource_type] -= amount

	# If resource is depleted, remove it from the dictionary
	if tile.resources[resource_type] <= 0:
		tile.resources.erase(resource_type)
		
		# If no resources left, remove the resources dictionary
		if tile.resources.size() == 0:
			# Simply remove the resources property instead of calling a method
			tile.resources = {} # Or you could use: tile.set("resources", {})
	
	# Emit signal that this tile changed
	emit_signal("tile_resource_changed", position)
	#print("Emitting tile_resource_changed signal for position: ", position)
	super.emit_signal("tile_resource_changed", position)

	return true
