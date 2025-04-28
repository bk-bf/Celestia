class_name Pathfinder
extends Resource

var grid: Grid 
var open_set: Array = []
var closed_set: Array = []

func _init(grid_reference: Grid):
	grid = grid_reference

func find_path(start_pos: Vector2, end_pos: Vector2) -> Array:
	# Reset sets
	open_set.clear()
	closed_set.clear()
	
	# Get start and end tiles
	var start_tile = grid.get_tile(start_pos)
	var end_tile = grid.get_tile(end_pos)
	
	# If start or end isn't walkable, return empty path
	if not start_tile.walkable or not end_tile.walkable:
		return []
	
	# Initialize start node with costs
	start_tile.g_cost = 0
	start_tile.h_cost = calculate_distance(start_tile, end_tile)
	start_tile.f_cost = start_tile.h_cost
	start_tile.parent = null
	
	# Add start tile to open set
	open_set.append(start_tile)
	
	while open_set.size() > 0:
		var current_tile = get_lowest_f_cost_tile()
		
		# If we reached the end
		if current_tile == end_tile:
			return reconstruct_path(end_tile)
		
		# Move current from open to closed set
		open_set.erase(current_tile)
		closed_set.append(current_tile)
		
		# Check all neighbors
		for neighbor in get_neighbors(current_tile):
			# Skip if not walkable or in closed set
			if not neighbor.walkable or closed_set.has(neighbor):
				continue
			
			# Calculate new path cost
			var new_cost = current_tile.g_cost + calculate_distance(current_tile, neighbor)
			
			# If new path is better or neighbor not in open set
			if new_cost < neighbor.g_cost or not open_set.has(neighbor):
				neighbor.g_cost = new_cost
				neighbor.h_cost = calculate_distance(neighbor, end_tile)
				neighbor.f_cost = neighbor.g_cost + neighbor.h_cost
				neighbor.parent = current_tile
				
				if not open_set.has(neighbor):
					open_set.append(neighbor)
	
	# No path found
	return []
	
# Helper functions
func calculate_distance(tile_a: Tile, tile_b: Tile) -> float:
	var pos_a = tile_a.get_coordinates()
	var pos_b = tile_b.get_coordinates()
	return abs(pos_a.x - pos_b.x) + abs(pos_a.y - pos_b.y)

func get_lowest_f_cost_tile() -> Tile:
	var lowest_cost_tile = open_set[0]
	
	for tile in open_set:
		if tile.f_cost < lowest_cost_tile.f_cost:
			lowest_cost_tile = tile
		# If equal f_cost, prefer tile with lower h_cost
		elif tile.f_cost == lowest_cost_tile.f_cost and tile.h_cost < lowest_cost_tile.h_cost:
			lowest_cost_tile = tile
	
	return lowest_cost_tile

func get_neighbors(tile: Tile) -> Array:
	# Get neighbors from the grid using the get_coordinates() method
	var neighbors = grid.get_neighbors(tile.get_coordinates())
	
	# Rest of your code remains the same
	var walkable_neighbors = []
	for neighbor in neighbors:
		if neighbor.walkable:
			neighbor.movement_cost = calculate_movement_cost(neighbor)
			walkable_neighbors.append(neighbor)
	
	return walkable_neighbors


func calculate_movement_cost(tile: Tile) -> float:
	# Load terrain database as a resource instead of using get_node
	var terrain_db = load("res://src/world/terrain/terrain_database.gd").new()
	
	# Default cost if biome not found in database
	var cost = 1.0
	
	# Get cost from terrain database if terrain exists
	if tile.terrain_type in terrain_db.terrain_definitions:
		cost = terrain_db.terrain_definitions[tile.terrain_type].get("movement_cost", 1.0)
	
	# Consider monster territory
	if tile.territory_owner != null:
		cost *= 1.5  # Pawns might want to avoid monster territories
	
	return cost

func reconstruct_path(end_tile: Tile) -> Array:
	var path = []
	var current = end_tile
	
	while current != null:
		path.append(current.get_coordinates())  # Use get_coordinates() instead of position
		current = current.parent
	
	path.reverse()
	return path
