extends Node2D

var map_data: MapData
@export var show_grid_lines: bool = true
@export var show_coordinate_numbers: bool = true
@export var cell_size: Vector2 = Vector2(16, 16)

@onready var camera = $Camera2D
var zoom_threshold = 1.5

func _ready():
	# Create a map with the same dimensions but procedurally generated
	map_data = MapData.new(Vector2i(50, 50), randi())
	generate_terrain()
	queue_redraw()
	
	# Print the statistics:
	print("map created with size: ", map_data.get_width(), "x", map_data.get_height())
	print("Average density: ", "%.2f" % map_data.get_average_density())
	print("Forest percentage: ", map_data.get_terrain_percentage("forest") * 100, "%")
	print("Water percentage: ", map_data.get_terrain_percentage("river") * 100, "%")
	
	var wood_tiles = map_data.find_tiles_with_resource("wood", 0.5)
	print("Found ", wood_tiles.size(), " tiles with significant wood resources")
	
	# Save the map data
	var save_path = "res://test_map.tres"
	var err = map_data.save_to_file(save_path)
	print("map saved with result: ", err)

# New function to generate terrain using noise
func generate_terrain():
	var noise_gen = NoiseGenerator.new(randi(), randi())
	
	# First pass: Generate basic terrain types and terrain_subtypes
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var grid_coords = Vector2i(x, y)
			var tile = map_data.get_tile(grid_coords)
			
			# Get noise values
			var terrain_val = noise_gen.get_terrain_noise(x, y)
			var detail_val = noise_gen.get_detail_noise(x, y)
			
			# Set tile density based on noise
			tile.density = (terrain_val + 1.0) / 2.0
			
			# Determine terrain type based on noise
			if terrain_val < -0.5:
				tile.terrain_type = "river"
				tile.set_water(true)
			elif terrain_val < -0.2:
				tile.terrain_type = "swamp"
			elif terrain_val < 0.2:
				tile.terrain_type = "plains"
			elif terrain_val < 0.6:
				tile.terrain_type = "forest"
				# Add wood resources to forests
				tile.resources["wood"] = 0.5 + (detail_val + 1.0) / 4.0
			else:
				tile.terrain_type = "mountain"
			
			# Set terrain_subtype based on detail noise
			determine_terrain_subtype(tile, detail_val)
	
	# Second pass: Process water proximity effects
	# handle_water_proximity()
	
	# Add some monster territories
	add_monster_territories()

# Helper function to determine tile terrain_subtypes
func determine_terrain_subtype(tile: Tile, detail_val: float):
	match tile.terrain_type:
		"forest":
			if detail_val < -0.6:
				tile.terrain_subtype = "dirt"
			elif detail_val < -0.2:
				tile.terrain_subtype = "grass"
			elif detail_val < 0.2:
				tile.terrain_subtype = "bush"
			elif detail_val < 0.6:
				tile.terrain_subtype = "deep_grass"
			else:
				tile.terrain_subtype = "tree"
		"swamp":
			if detail_val < -0.6:
				tile.terrain_subtype = "shallow_water"
			elif detail_val < -0.2:
				tile.terrain_subtype = "mud"
			elif detail_val < 0.2:
				tile.terrain_subtype = "bog"
			elif detail_val < 0.6:
				tile.terrain_subtype = "clay"
			else:
				tile.terrain_subtype = "moss"
		"mountain":
			if detail_val < -0.3:
				tile.terrain_subtype = "rocky"
			else:
				tile.terrain_subtype = "peak"

# Process water proximity effects
# func handle_water_proximity():
	# Code commented out in original

# Add monster territories - NO DRAWING, just data setup
func add_monster_territories():
	# Find suitable locations for territories based on terrain
	var forest_tiles = []
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var coords = Vector2i(x, y)
			var tile = map_data.get_tile(coords)
			if tile.terrain_type == "forest" and !tile.is_water():
				forest_tiles.append(coords)
	
	# Place wolf pack territories in forests
	if forest_tiles.size() > 0:
		var wolf_center = forest_tiles[randi() % forest_tiles.size()]
		map_data.register_monster_territory(wolf_center, 8.0, "wolf_pack")
		
		# If enough forest, add a second pack
		if forest_tiles.size() > 100:
			# Find a spot far from the first pack
			var second_center = forest_tiles[0]
			var max_distance = 0
			for coords in forest_tiles:
				var dist = coords.distance_to(wolf_center)
				if dist > max_distance:
					max_distance = dist
					second_center = coords
			map_data.register_monster_territory(second_center, 6.0, "wolf_pack")

# Main drawing function - ALL drawing must happen here
func _draw():
	if !map_data:
		return
		
	# 1. Draw tile colors (background layer)
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var grid_coords = Vector2i(x, y)
			var tile = map_data.get_tile(grid_coords)
			var rect = Rect2(
				x * cell_size.x, 
				y * cell_size.y, 
				cell_size.x, 
				cell_size.y
			)
			
			# Choose color based on tile properties
			var color = Color.GREEN
			if tile.is_water():
				color = Color(0.3, 0.5, 0.9, 0.6)  # Blue for water
			elif tile.terrain_type == "mountain":
				var mountain_color = Color(0.6, 0.6, 0.6, 0.6)
				# Darker for higher density
				mountain_color = mountain_color.darkened(tile.density * 0.5)
				color = mountain_color
			elif tile.terrain_type == "forest":
				color = Color.DARK_GREEN
			elif tile.terrain_type == "swamp":
				color = Color(0.4, 0.5, 0.3, 0.8)  # Murky green
				
			# Modify color based on tile variation
			match tile.terrain_subtype:
				"tree":
					color = color.darkened(0.2)
				"deep_grass":
					color = color.lightened(0.1)
				"moss":
					color = Color(0.3, 0.6, 0.3, 0.7)
					
			draw_rect(rect, color)
	
	# 2. Draw grid lines
	if show_grid_lines:
		var width = map_data.get_width() * cell_size.x
		var height = map_data.get_height() * cell_size.y
		
		# Draw vertical lines
		for x in range(map_data.get_width() + 1):
			var start = Vector2(x * cell_size.x, 0)
			var end = Vector2(x * cell_size.x, height)
			draw_line(start, end, Color.DARK_GRAY, 1.0)
			
		# Draw horizontal lines
		for y in range(map_data.get_height() + 1):
			var start = Vector2(0, y * cell_size.y)
			var end = Vector2(width, y * cell_size.y)
			draw_line(start, end, Color.DARK_GRAY, 1.0)
	
	# 3. Draw text and territory markers
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var grid_coords = Vector2i(x, y)
			var tile = map_data.get_tile(grid_coords)
			var map_pos = map_data.grid_to_map(grid_coords)
			
			# Territory indicator
			if tile.territory_owner != "":
				var center = Vector2(
					x * cell_size.x + cell_size.x / 2,
					y * cell_size.y + cell_size.y / 2
				)
				draw_circle(center, cell_size.x / 6, Color(0.9, 0.2, 0.2, 0.7))
			
			# Coordinate numbers
			if show_coordinate_numbers:
				var custom_font = preload("res://assets/fonts/Roboto_Condensed/RobotoCondensed-Bold.ttf")
				var font_size = 4
				var label = "(%d,%d)" % [x, y]
				
				var text_size = custom_font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
				var text_pos = Vector2(
					x * cell_size.x + (cell_size.x - text_size.x) / 2,
					y * cell_size.y + (cell_size.y + text_size.y) / 2
				)
				if camera.zoom.x <= zoom_threshold:
					draw_string(custom_font, text_pos, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
