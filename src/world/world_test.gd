extends Node2D

var world_data: WorldData

func _ready():
	# Create a small test world
	world_data = WorldData.new(Vector2i(50, 50), randi())
	queue_redraw()
	
	# Modify some tiles for testing
	for y in range(10, 20):
		for x in range(15, 25):
			var tile = world_data.get_tile(Vector2i(x, y))
			tile.biome_type = "forest"
			tile.altitude = 0.7
			tile.resources["wood"] = 0.8
	
	# Create a water feature
	for y in range(30, 40):
		for x in range(5, 45):
			var tile = world_data.get_tile(Vector2i(x, y))
			tile.biome_type = "river"
			tile.altitude = -0.2
	
	# Register a monster territory
	world_data.register_monster_territory(Vector2i(35, 15), 8.0, "wolf_pack")
	
	# Print some statistics
	print("World created with size: ", world_data.get_width(), "x", world_data.get_height())
	print("Average altitude: ", world_data.get_average_altitude())
	print("Forest percentage: ", world_data.get_biome_percentage("forest") * 100, "%")
	print("Water percentage: ", world_data.get_biome_percentage("river") * 100, "%")
	
	var wood_tiles = world_data.find_tiles_with_resource("wood", 0.5)
	print("Found ", wood_tiles.size(), " tiles with significant wood resources")
	
	# Save the world data
	var save_path = "res://test_world.tres"
	var err = world_data.save_to_file(save_path)
	print("World saved with result: ", err)

# Add this visualization function
func _draw():
	var tile_size = 10  # Size of each tile in pixels
	
	for y in range(world_data.get_height()):
		for x in range(world_data.get_width()):
			var tile = world_data.get_tile(Vector2i(x, y))
			var rect = Rect2(x * tile_size, y * tile_size, tile_size, tile_size)
			
			# Choose color based on biome type
			var color = Color.WHITE
			match tile.biome_type:
				"plains":
					color = Color(0.5, 0.8, 0.3)  # Light green
				"forest":
					color = Color(0.2, 0.6, 0.2)  # Darker green
				"river", "lake", "ocean":
					color = Color(0.3, 0.5, 0.9)  # Blue
				_:
					color = Color(0.8, 0.8, 0.7)  # Default tan
			
			# Modify color based on altitude
			if tile.altitude > 0:
				color = color.lightened(tile.altitude * 0.3)
			else:
				color = color.darkened(-tile.altitude * 0.3)
			
			# Draw the tile
			draw_rect(rect, color)
			
			# Draw territory markers
			if tile.territory_owner != "":
				var center = Vector2(x * tile_size + tile_size/2, y * tile_size + tile_size/2)
				draw_circle(center, tile_size/4, Color.RED)
