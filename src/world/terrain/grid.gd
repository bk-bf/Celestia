class_name Grid
extends Resource

# Grid dimensions
@export var width: int = 100
@export var height: int = 100

# Define your cell size (in pixels)
@export var cell_size: Vector2 = Vector2(16, 16)

# Storage for tiles
var _tiles: Array = []  # Will store Tile objects in a 1D array
var _half_cell_size: Vector2
@export var chunk_size: int = 16  # For potential future optimization

# Initialization
func _init(w: int = 100, h: int = 100, cell_sz: Vector2 = Vector2(16, 16)):
	width = w
	height = h
	cell_size = cell_sz
	_half_cell_size = cell_size / 2
	_initialize_grid()

# Convert grid coordinates to map position (center of tile)
func grid_to_map(grid_coords: Vector2i) -> Vector2:
	return Vector2(grid_coords) * cell_size + _half_cell_size

# Convert map position to grid coordinates
func map_to_grid(map_pos: Vector2) -> Vector2i:
	return Vector2i((map_pos / cell_size).floor())
	map_pos.x = clamp(map_pos.x, 0, width - 1)
	map_pos.y = clamp(map_pos.y, 0, height - 1)
	
	return map_pos
	
# Create empty tiles for the entire grid
func _initialize_grid() -> void:
	_tiles.clear()
	_tiles.resize(width * height)
	
	for y in range(height):
		for x in range(width):
			var coords = Vector2i(x, y)
			var tile = Tile.new(coords)
			set_tile(coords, tile)

# Helper methods
func get_index(coords: Vector2i) -> int:
	return coords.y * width + coords.x

func is_valid_coordinates(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.x < width and coords.y >= 0 and coords.y < height

func get_tile(coords: Vector2i) -> Tile:
	if not is_valid_coordinates(coords):
		push_error("Attempted to access tile outside grid boundaries: " + str(coords))
		return null
		
	var index = get_index(coords)
	return _tiles[index]

func set_tile(coords: Vector2i, tile: Tile) -> void:
	if not is_valid_coordinates(coords):
		push_error("Attempted to set tile outside grid boundaries: " + str(coords))
		return
		
	var index = get_index(coords)
	_tiles[index] = tile
	
	# Update tile coordinates to match its position in the grid
	tile.x = coords.x
	tile.y = coords.y

# Get neighboring tiles (8-way: north, east, south, west and diagonals)
func get_neighbors(coords: Vector2i) -> Array:
	var neighbors = []
	var directions = [
		Vector2i(0, -1),  # North
		Vector2i(1, 0),   # East
		Vector2i(0, 1),   # South
		Vector2i(-1, 0),  # West
		Vector2i(1, -1),  # Northeast
		Vector2i(1, 1),   # Southeast
		Vector2i(-1, 1),  # Southwest
		Vector2i(-1, -1)  # Northwest
	]
	
	for dir in directions:
		var neighbor_coords = coords + dir
		if is_valid_coordinates(neighbor_coords):
			var neighbor = get_tile(neighbor_coords)
			
			# For diagonal movement, check if we're cutting through walls
			if abs(dir.x) == 1 and abs(dir.y) == 1:
				# Check the two adjacent orthogonal tiles
				var ortho1 = get_tile(Vector2i(coords.x + dir.x, coords.y))
				var ortho2 = get_tile(Vector2i(coords.x, coords.y + dir.y))
				
				# Only allow diagonal if at least one orthogonal neighbor is walkable
				if (ortho1 != null and ortho1.walkable) or (ortho2 != null and ortho2.walkable):
					neighbors.append(neighbor)
			else:
				# Orthogonal movement is always allowed
				neighbors.append(neighbor)
			
	return neighbors



# Get all 8 surrounding tiles
func get_neighbors_surrounding(coords: Vector2i) -> Array:
	var neighbors = []
	for y in range(-1, 2):
		for x in range(-1, 2):
			if x == 0 and y == 0:
				continue
			var neighbor_coords = coords + Vector2i(x, y)
			if is_valid_coordinates(neighbor_coords):
				neighbors.append(get_tile(neighbor_coords))
				
	return neighbors
	
