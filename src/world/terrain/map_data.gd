## Map data class that stores and manages all terrain and map information.
## Responsible for storing tile data, territory information, and resource distribution.
##
## Properties:
## - map_seed: Seed used for map generation
## - map_size: Size of the map in grid cells
## - terrain_grid: Main grid data structure containing all tiles
##
## Signals:
## - tile_resource_changed: Emitted when a resource is consumed at a location

class_name MapData
extends Resource

# Database references
var territory_database = DatabaseManager.territory_database
var terrain_database = DatabaseManager.terrain_database
var pathfinder = Pathfinder

# Core terrain grid
@export var terrain_grid: Grid

# Map properties
@export var map_seed: int = 0
@export var map_name: String = "Celestia Map"
@export var map_size: Vector2i = Vector2i(200, 200)

# Territory configuration
const MAX_TERRITORY_SIZE: int = 700
const MIN_TERRITORY_COUNT: int = 100
const MAX_TERRITORY_COUNT: int = 200
const TERRITORY_COVERAGE_PERCENTAGE: float = 0.8

# Data structures for terrain analysis
var terrain_distribution: Dictionary = {}
var resource_maps: Dictionary = {}
var monster_territories: Array = []
var rivers: Array = []
var lakes: Array = []
var ocean_tiles: Array = []

# Utilities
var tile_data = TileData.new()

# Signals
signal tile_resource_changed(position)

# Initialization
func _init(size: Vector2i = Vector2i(200, 200), set_seed: int = 0) -> void:
    map_size = size
    map_seed = set_seed
    initialize_grid()
    initialize_pathfinder()

# Initializes the terrain grid
func initialize_grid() -> void:
    terrain_grid = Grid.new(map_size.x, map_size.y)

# Initializes the pathfinder system
func initialize_pathfinder() -> void:
    pathfinder = Pathfinder.new(terrain_grid)

# Save and load functionality
func save_to_file(path: String) -> Error:
    return ResourceSaver.save(self, path)

static func load_from_file(path: String) -> MapData:
    if ResourceLoader.exists(path):
        return ResourceLoader.load(path) as MapData
    return null

# Basic tile getters and setters
func get_tile(coords: Vector2i) -> Tile:
    return terrain_grid.get_tile(coords)

func set_tile(coords: Vector2i, tile: Tile) -> void:
    terrain_grid.set_tile(coords, tile)

# Map dimensions
func get_width() -> int:
    return map_size.x

func get_height() -> int:
    return map_size.y

# Coordinate conversion
func grid_to_map(grid_coords: Vector2i) -> Vector2:
    return terrain_grid.grid_to_map(grid_coords)

func map_to_grid(map_pos: Vector2) -> Vector2i:
    return terrain_grid.map_to_grid(map_pos)

func get_tile_size() -> Vector2:
    return terrain_grid.cell_size

# Map bounds checking
func is_within_bounds_map(map_pos: Vector2) -> bool:
    var grid_coords = map_to_grid(map_pos)
    return terrain_grid.is_valid_coordinates(grid_coords)

#
# Terrain Analysis Methods
#

# Calculate average terrain density across the map
func get_average_density() -> float:
    var sum = 0.0
    var count = 0

    for y in range(get_height()):
        for x in range(get_width()):
            var tile = get_tile(Vector2i(x, y))
            sum += tile.density
            count += 1

    return sum / count if count > 0 else 0.5 # Default to normal ground density

# Get a suitable starting position near map center
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

# Calculate percentage of walkable tiles
func get_walkable_percentage() -> float:
    var count = 0
    var total = get_width() * get_height()

    for y in range(get_height()):
        for x in range(get_width()):
            var tile = get_tile(Vector2i(x, y))
            if tile.walkable:
                count += 1

    return float(count) / total

# Get resources at a specific position
func get_resources_at(position: Vector2i):
    var tile = get_tile(position)
    if tile and "resources" in tile:
        return tile.resources
    return null

# Calculate percentage of map with a specific terrain type
func get_terrain_percentage(terrain_type: String) -> float:
    var count = 0
    var total = get_width() * get_height()

    for y in range(get_height()):
        for x in range(get_width()):
            var tile = get_tile(Vector2i(x, y))
            if tile.terrain_type == terrain_type:
                count += 1

    return float(count) / float(total) if total > 0 else 0.0

# Calculate percentage of map with a specific subterrain type
func get_subterrain_percentage(subterrain_type: String) -> float:
    var count = 0
    var total = get_width() * get_height()

    for y in range(get_height()):
        for x in range(get_width()):
            var tile = get_tile(Vector2i(x, y))
            if tile.terrain_subtype == subterrain_type:
                count += 1

    return float(count) / total if total > 0 else 0.0

#
# Tile Filtering Methods
#

# Find all tiles of a specific terrain type
func find_tiles_by_terrain(terrain_type: String) -> Array:
    var matching_tiles = []

    for y in range(get_height()):
        for x in range(get_width()):
            var tile = get_tile(Vector2i(x, y))
            if tile.terrain_type == terrain_type:
                matching_tiles.append(tile)

    return matching_tiles

# Find all tiles within a density range
func find_tiles_by_density_range(min_density: float, max_density: float) -> Array:
    var matching_tiles = []

    for y in range(get_height()):
        for x in range(get_width()):
            var tile = get_tile(Vector2i(x, y))
            if tile.density >= min_density and tile.density <= max_density:
                matching_tiles.append(tile)

    return matching_tiles

#
# Territory Management
#

# Create and register monster territories on the map
func register_monster_territories() -> void:
    # First, group territories by preferred terrain
    var territories_by_terrain = group_territories_by_terrain()

    # For each terrain type, create territories
    for terrain_type in territories_by_terrain.keys():
        create_territories_for_terrain(terrain_type, territories_by_terrain[terrain_type])

# Group monster territories by their preferred terrain
func group_territories_by_terrain() -> Dictionary:
    var territories_by_terrain = {}

    # Organize monsters by their preferred terrain
    for territory_type in territory_database.territory_definitions.keys():
        var preferred_terrains = territory_database.territory_definitions[territory_type]["preferred_terrain"]
        for terrain in preferred_terrains:
            if not territories_by_terrain.has(terrain):
                territories_by_terrain[terrain] = []
            territories_by_terrain[terrain].append(territory_type)

    return territories_by_terrain

# Create territories for a specific terrain type
func create_territories_for_terrain(terrain_type: String, possible_monsters: Array) -> void:
    var suitable_tiles = find_tiles_by_terrain(terrain_type)

    # Skip if no suitable tiles
    if suitable_tiles.size() == 0:
        return

    # Apply rarity filter for monster selection
    var weighted_monsters = weight_monsters_by_rarity(possible_monsters)

    # Determine number of territories to create
    var territory_count = calculate_territory_count(suitable_tiles.size())

    # Assign territories
    for _i in range(territory_count):
        # Pick a random monster type with rarity weighting
        var monster_type = weighted_monsters[randi() % weighted_monsters.size()]

        # Create a territory seed point
        var seed_point = suitable_tiles[randi() % suitable_tiles.size()]

        # Expand territory from seed point
        expand_territory_from_seed(seed_point, monster_type, terrain_type)

# Weight monsters by their rarity for random selection
func weight_monsters_by_rarity(possible_monsters: Array) -> Array:
    var weighted_monsters = []
    for monster_type in possible_monsters:
        var rarity = territory_database.territory_definitions[monster_type]["rarity"]
        # Add the monster to the selection pool 'rarity' number of times
        for _i in range(rarity):
            weighted_monsters.append(monster_type)
    return weighted_monsters

# Calculate how many territories to create based on available tiles
func calculate_territory_count(available_tiles: int) -> int:
    var territory_count = int(available_tiles * TERRITORY_COVERAGE_PERCENTAGE)
    return max(MIN_TERRITORY_COUNT, min(territory_count, MAX_TERRITORY_COUNT))

# Expand a territory from a seed point using flood fill
func expand_territory_from_seed(seed_point: Vector2i, monster_type: String, terrain_type: String, max_size: int = MAX_TERRITORY_SIZE) -> void:
    # Create a queue for flood fill algorithm
    var queue = []
    queue.push_back(seed_point)

    # Keep track of tiles we've already processed
    var processed_tiles = {}
    processed_tiles[Vector2i(seed_point.x, seed_point.y)] = true

    # Keep track of how many tiles we've added to this territory
    var territory_size = 0

    # Process the queue until empty or we reach max size
    while queue.size() > 0 and territory_size < max_size:
        process_territory_tile(queue, processed_tiles, monster_type, terrain_type, territory_size)

    # Record territory in list
    monster_territories.append({
        "seed": seed_point,
        "monster_type": monster_type,
        "size": territory_size
    })

# Process a single tile during territory expansion
func process_territory_tile(queue: Array, processed_tiles: Dictionary, monster_type: String, terrain_type: String, territory_size: int) -> void:
    # Get the next tile to process
    var current = queue.pop_front()

    # Get the current tile
    var tile = get_tile(current)

    # Skip if this tile already has a territory owner with a different coexistence layer
    if handle_territory_ownership(tile, monster_type):
        return

    # Skip if this tile isn't the preferred terrain type
    if tile["terrain_type"] != terrain_type:
        return

    # Skip if this tile isn't walkable (water/river)
    if not tile["walkable"]:
        return

    # Assign territory to this tile
    tile["territory_owner"] = monster_type
    territory_size += 1

    # Add neighboring tiles to the queue
    add_neighbors_to_queue(current, queue, processed_tiles)

# Handle territory ownership and coexistence
func handle_territory_ownership(tile, monster_type: String) -> bool:
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
                    return true # Skip if already in the list

                # Get the coexistence layer of the first territory
                current_layer = territory_database.territory_definitions[owners[0]]["coexistence_layer"]

                if current_layer != new_layer:
                    return true # Skip if layers don't match
                else:
                    # Add to existing comma-separated list
                    tile["territory_owner"] = current_owner + "," + monster_type
            else:
                # Single territory owner
                current_layer = territory_database.territory_definitions[current_owner]["coexistence_layer"]

                # Skip if it's the same monster type
                if current_owner == monster_type:
                    return true

                if current_layer != new_layer:
                    return true # Skip if layers don't match
                else:
                    # Territories can coexist, store as a list
                    tile["territory_owner"] = current_owner + "," + monster_type
        else: # Array of territory owners
            # Get the coexistence layer of the first territory (assuming all have the same layer)
            current_layer = territory_database.territory_definitions[current_owner[0]]["coexistence_layer"]

            if current_layer != new_layer:
                return true # Skip if layers don't match
            elif not monster_type in current_owner: # Avoid duplicates
                # Add to existing array
                tile["territory_owner"].append(monster_type)
            else:
                return true # Skip if already in the list

    return false

# Add neighboring tiles to the territory expansion queue
func add_neighbors_to_queue(current: Vector2i, queue: Array, processed_tiles: Dictionary) -> void:
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

#
# Territory Analysis
#

# Count territories of a specific monster type
func count_territories_by_type(monster_type: String) -> int:
    var count = 0
    for territory in monster_territories:
        if territory["monster_type"] == monster_type:
            count += 1
    return count

# Calculate percentage of map covered by territories
func get_territory_coverage() -> float:
    var territory_count = 0
    var total = get_width() * get_height()
    for y in range(get_height()):
        for x in range(get_width()):
            var tile = get_tile(Vector2i(x, y))
            if tile.territory_owner != "":
                territory_count += 1

    return float(territory_count) / total if total > 0 else 0.0

# Get dictionary of territory owners and their tile counts
func get_territory_owners() -> Dictionary:
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

#
# Resource Management
#

# Reduce resource at a specific position
func reduce_resource_at(position: Vector2i, amount: int) -> bool:
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
            tile.resources = {}

    # Emit signal that this tile changed
    emit_signal("tile_resource_changed", position)
    super.emit_signal("tile_resource_changed", position)

    return true

#
# Terrain Generation
#

# Generate terrain for the entire map
func generate_terrain(width: int, height: int) -> void:
    var noise_gen = NoiseGenerator.new()

    generate_basic_terrain(width, height, noise_gen)
    apply_terrain_details(width, height, noise_gen)

# Generate basic terrain types for the first pass
func generate_basic_terrain(width: int, height: int, noise_gen: NoiseGenerator) -> void:
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

# Apply detail terrain subtypes and environmental effects
func apply_terrain_details(width: int, height: int, noise_gen: NoiseGenerator) -> void:
    # Second pass: Apply detail terrain_subtypes and water proximity effects
    for y in range(height):
        for x in range(width):
            var grid_coords = Vector2i(x, y)
            var tile = get_tile(grid_coords)
            var detail_val = noise_gen.get_detail_noise(x, y)

            # Calculate proximity to water for terrain blending
            var water_proximity = calculate_water_proximity(x, y)

            # Apply special handling for water borders
            if water_proximity > 0 && !tile.is_water():
                apply_water_proximity_effects(tile, detail_val)
            else:
                # Normal terrain_subtype assignment for tiles not near water
                tile.terrain_subtype = determine_terrain_subtype(tile.terrain_type, detail_val)

# Calculate water proximity for terrain blending
func calculate_water_proximity(x: int, y: int) -> float:
    var water_proximity = 0.0
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            var check_pos = Vector2i(x + dx, y + dy)
            if is_within_bounds_map(check_pos):
                var neighbor = get_tile(check_pos)
                if neighbor.is_water():
                    water_proximity += 0.1
    return water_proximity

# Apply terrain effects based on water proximity
func apply_water_proximity_effects(tile: Tile, detail_val: float) -> void:
    if tile.terrain_type == "mountain":
        # Mountains near water become rocky cliffs
        tile.terrain_subtype = "rocky_cliff"
    elif tile.terrain_type == "forest":
        # Forests near water become sparse
        tile.terrain_subtype = "sparse_trees"
    else:
        # For other terrain types, apply normal terrain_subtypes
        tile.terrain_subtype = determine_terrain_subtype(tile.terrain_type, detail_val)

# Determine the terrain type based on density value
func determine_terrain_type(density: float) -> String:
    return tile_data.get_terrain_type(density)

# Determine the terrain subtype based on terrain type and detail value
func determine_terrain_subtype(terrain_type: String, detail_val: float) -> String:
    var terrain_subtype = tile_data.terrain_definitions[terrain_type].variations

    # Select terrain subtype based on detail_val
    var normalized_detail = (detail_val + 1.0) / 2.0 # Convert from -1,1 to 0,1
    var index = floor(normalized_detail * terrain_subtype.size())
    index = clamp(index, 0, terrain_subtype.size() - 1)

    return terrain_subtype[index]