extends Node2D

var map_data: MapData
@export var show_grid_lines: bool = true
@export var cell_size: Vector2 = Vector2(16, 16)

func _ready():
	# Create a small test map
	map_data = MapData.new(Vector2i(50, 50), randi())
	queue_redraw()
	
	# Modify some tiles for testing
	for y in range(10, 20):
		for x in range(15, 25):
			var tile = map_data.get_tile(Vector2i(x, y))
			tile.biome_type = "forest"
			tile.density = 0.5
			tile.resources["wood"] = 0.8
	
	# Create a water feature
	for y in range(30, 40):
		for x in range(5, 45):
			var tile = map_data.get_tile(Vector2i(x, y))
			tile.biome_type = "river"
			tile.density = -0.2
	
	# Register a monster territory
	map_data.register_monster_territory(Vector2i(35, 15), 8.0, "wolf_pack")
	
	# Print some statistics
	print("World created with size: ", map_data.get_width(), "x", map_data.get_height())
	print("Average density: ", "%.2f" % map_data.get_average_density())
	print("Forest percentage: ", map_data.get_biome_percentage("forest") * 100, "%")
	print("Water percentage: ", map_data.get_biome_percentage("river") * 100, "%")
	
	var wood_tiles = map_data.find_tiles_with_resource("wood", 0.5)
	print("Found ", wood_tiles.size(), " tiles with significant wood resources")
	
	# Save the map data
	var save_path = "res://test_map.tres"
	var err = map_data.save_to_file(save_path)
	print("World saved with result: ", err)

# Add this visualization function
func _draw():
	if !map_data:
		return
		
	# Draw grid lines
	if show_grid_lines:
		var width = map_data.get_width() * cell_size.x
		var height = map_data.get_height() * cell_size.y
		
		# Draw vertical lines
		for x in range(map_data.get_width() + 1):
			var start = Vector2(x * cell_size.x, 0)
			var end = Vector2(x * cell_size.x, height)
			draw_line(start, end, Color.GRAY, 1.0)
			
		# Draw horizontal lines
		for y in range(map_data.get_height() + 1):
			var start = Vector2(0, y * cell_size.y)
			var end = Vector2(width, y * cell_size.y)
			draw_line(start, end, Color.GRAY, 1.0)

# Test coordinate conversion
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var grid_coords = Vector2i(x, y)
			var world_pos = map_data.grid_to_world(grid_coords)
			
			# Draw coordinate text for a few tiles
			if x % 5 == 0 and y % 5 == 0:
				draw_string(ThemeDB.fallback_font, world_pos + Vector2(2, -2), 
		   "(%d,%d)" % [x, y], HORIZONTAL_ALIGNMENT_CENTER, -1, 12)
	
