extends Node2D

var map_data: MapData
var terrain_database: TerrainDatabase
var territory_database = TerritoryDatabase.new() # Add monsters database

@export var show_grid_lines: bool = true
@export var show_coordinate_numbers: bool = true
@export var show_terrain_letters: bool = true
@export var show_density_values: bool = true
@export var show_territory_frequency: bool = true
#@export var show_territory_noise: bool = true

@export var cell_size: Vector2 = Vector2(16, 16)
@export var seed: int = 0 # If left as 0, a random seed will be used
var detail_seed: int = 0
var territory_seed: int = 0 # Derived seed for territories

@onready var camera = $Camera2D
var zoom_threshold = 1.5

# Import the statistics class
const MapStatistics = preload("res://src/world/terrain/statistics.gd")

func _ready():
	# Initialize terrain database
	terrain_database = TerrainDatabase.new()
	# Check if seeds are 0 and generate random seeds if needed
	if seed == 0:
		seed = randi()
		
	detail_seed = seed * 6971 # multiplied with prime
	territory_seed = seed * 7919 # Using different prime multiplier
 	# Create a map with the same dimensions but procedurally generated
	map_data = MapData.new(Vector2i(200, 200), randi())

	# Generate terrain with stored seeds
	generate_terrain(seed, detail_seed)
	queue_redraw()
	
	MapStatistics.print_map_statistics(map_data, terrain_database, seed, detail_seed, territory_seed)
	
	# Save the map data
	var save_path = "res://test_map.tres"
	var err = map_data.save_to_file(save_path)
	print("map saved with result: ", err)
	
	# Create an instance of MapStatistics
	var map_stats = MapStatistics.new()
	# Set required properties on the instance
	map_stats.map_data = map_data
	map_stats.seed = seed
	map_stats.detail_seed = detail_seed
	# Call the save_statistics_to_file method on the instance
	# map_stats.save_statistics_to_file() # this shit fails with error 7 but the directory it safes to exists and is always writeable
	
# function to generate terrain using noise and TerrainDatabase
func generate_terrain(seed = null, detail_seed = null):
	# Use provided seeds or generate new ones
	seed = seed if seed != null else randi()
	detail_seed = detail_seed if detail_seed != null else randi()

	var noise_gen = NoiseGenerator.new(seed, detail_seed)
	
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
			
			# Determine terrain type based on density using TerrainDatabase
			tile.terrain_type = terrain_database.get_terrain_type(tile.density)
			
			# Check if this terrain has is_water property and set it
			if tile.terrain_type in terrain_database.terrain_definitions and "is_water" in terrain_database.terrain_definitions[tile.terrain_type]:
				tile.set_water(terrain_database.terrain_definitions[tile.terrain_type].is_water)
			
			# Set resources based on terrain type
			# Instead of hardcoding "forest", check if the terrain type has associated resources
			if tile.terrain_type in terrain_database.terrain_definitions:
				var terrain_def = terrain_database.terrain_definitions[tile.terrain_type]
				# Check if terrain has resource property or use our knowledge about forest->wood
				if "resource" in terrain_def:
					tile.resources[terrain_def.resource] = 0.5 + (detail_val + 1.0) / 4.0
				elif tile.terrain_type == "forest":  # Fallback for backward compatibility
					tile.resources["wood"] = 0.5 + (detail_val + 1.0) / 4.0
			
			# Set terrain_subtype based on detail noise using TerrainDatabase
			tile.terrain_subtype = terrain_database.get_subterrain(tile.terrain_type, detail_val)
			
			# Set walkable property based on terrain and subterrain
			tile.walkable = terrain_database.is_walkable(tile.terrain_type, tile.terrain_subtype)

# Updated monster territories function using TerritoryDatabase
func add_monster_territories(territory_seed = null):
	# Set the seed for reproducible results
	if territory_seed != null:
		seed(territory_seed)
	
	# Get monster types from database
	var available_monster_types = territory_database.get_monster_types()
	
	# Choose different base seeds for each monster type to ensure separation
	for i in range(available_monster_types.size()):
		var monster_type = available_monster_types[i]
		var monster_data = territory_database.get_monster_data(monster_type)
		
		# Create a unique seed for this monster territory
		var monster_seed = territory_seed + (i * 1000)
		
		# Register the territory with values from database
		map_data.register_monster_territory(
			monster_seed,
			monster_type,
			monster_data.territory_frequency,
			monster_data.territory_threshold
		)
	
	print("Generated " + str(available_monster_types.size()) + " monster territories") 

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
			
			# Get base color from terrain database
			var base_color = Color.WHITE # Default color if terrain type isn't found
			if tile.terrain_type in terrain_database.terrain_definitions:
				base_color = terrain_database.terrain_definitions[tile.terrain_type].base_color
			
			# Apply subterrain modification if applicable
			var color = base_color
			if tile.terrain_subtype != "":
				color = terrain_database.get_modified_color(base_color, tile.terrain_subtype)
			
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
	
	# Get the first letter of the territory name, uppercase
	
	# 3. Draw text and territory markers
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			
			var grid_coords = Vector2i(x, y)
			var tile = map_data.get_tile(grid_coords)
			var territory_letter = tile.territory_owner.substr(0, 1).to_upper()
			var custom_font = preload("res://assets/fonts/Roboto_Condensed/RobotoCondensed-Bold.ttf")
			var font_size = 4
			var text_size = custom_font.get_string_size(territory_letter, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
			var map_pos = map_data.grid_to_map(grid_coords)
			
			# Territory indicator
			if tile.territory_owner != "":
				var center = Vector2(
					x * cell_size.x + cell_size.x / 2,
					y * cell_size.y + cell_size.y / 2
				)
				
				# Calculate position to center the letter
				var text_pos = Vector2(
					center.x - text_size.x / 2,
					center.y + text_size.y / 2
				)
				
				# Get color from territory_database on territory_owner
				var letter_color = Color(0.9, 0.2, 0.2, 0.9)  # Default red fallback
				if territory_database and tile.territory_owner in territory_database.territory_definitions:
					var monster_data = territory_database.territory_definitions[tile.territory_owner]
					if "color" in monster_data:
						letter_color = monster_data.color

				
				# Draw the letter
				draw_string(custom_font, text_pos, territory_letter, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, letter_color)
			
			# Coordinate numbers
			if show_coordinate_numbers:
				var label = "(%d,%d)" % [x, y]
				
				var text_pos = Vector2(
					x * cell_size.x + (cell_size.x - text_size.x) / 2,
					y * cell_size.y + (cell_size.y + text_size.y) / 2
				)
				if camera.zoom.x <= zoom_threshold:
					draw_string(custom_font, text_pos, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
			
			# Density value display
			if show_density_values:
				var density_str = "%.1f" % tile.density # Format to 1 decimal place
				
				# Position the density in the lower-right corner of the tile
				var density_pos = Vector2(
					(x + 1) * cell_size.x - 2 - custom_font.get_string_size(density_str, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size).x,
					(y + 1) * cell_size.y - 2
				)
				
				# Use a contrasting color for visibility
				var density_color = Color.WHITE
				if tile.is_water():
					density_color = Color.WHITE
				elif tile.terrain_type == "mountain":
					density_color = Color.BLACK
				
				if camera.zoom.x <= zoom_threshold * 1.5:
					draw_string(custom_font, density_pos, density_str, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, density_color)
			# In your existing _draw() function, after or near density display
			
			if show_territory_frequency:
						# Position this slightly above density values for clarity
						# Calculate monster frequency for this tile (if not already stored)
						var territory_freq = 0.0
						if tile.territory_owner != "":
							# If you have the actual frequency stored in monsters_database
							if territory_database and tile.territory_owner in territory_database.territory_definitions:
								territory_freq = territory_database.get_territory_frequency(tile.territory_owner)
						
						var freq_str = "%.2f" % territory_freq
						
						# Position the frequency in the lower-right corner above the density value
						var freq_pos = Vector2(
							(x + 1) * cell_size.x - 2 - custom_font.get_string_size(freq_str, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size).x,
							(y + 1) * cell_size.y - 12  # Position above density value
						)
						
						# Use a distinct color for monster frequency
						var freq_color = Color.ORANGE
						
						if camera.zoom.x <= zoom_threshold * 1.5:
							draw_string(custom_font, freq_pos, freq_str, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, freq_color)
			
			# Terrain/subterrain type display
			if show_terrain_letters:
				# Get first letter of terrain and subterrain
				var terrain_letter = tile.terrain_type.substr(0, 1).to_upper()
				var subterrain_letter = ""
				if tile.terrain_subtype != "":
					subterrain_letter = tile.terrain_subtype.substr(0, 1).to_upper()
				
				# Format as "T/S" or just "T" if no subterrain
				var type_label = terrain_letter
				if subterrain_letter != "":
					type_label = terrain_letter + "/" + subterrain_letter
				
				# Position in center-top of tile
				var label_pos = Vector2(
					x * cell_size.x + cell_size.x / 2 - custom_font.get_string_size(type_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x / 2,
					y * cell_size.y + font_size + 2
				)
				
				# Choose contrasting colors based on terrain type
				var label_color = Color.WHITE
				if tile.terrain_type == "forest":
					label_color = Color.WHITE
				elif tile.is_water():
					label_color = Color.WHITE
				
				if camera.zoom.x <= zoom_threshold * 1.5:
					draw_string(custom_font, label_pos, type_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, label_color)
				
