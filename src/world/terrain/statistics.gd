extends Node
class_name MapStatistics

var map_data: MapData
@export var seed: int = 0 # If left as 0, a random seed will be used
@export var detail_seed: int = 0 # If left as 0, a random seed will be used
@export var territory_seed: int = 0

# Function to print statistics about a map
static func print_map_statistics(map_data, terrain_database, seed = null, detail_seed = null, territory_seed = null):
	print("\n=== CELESTIA MAP STATISTICS ===")
	print("Map dimensions: ", map_data.get_width(), "x", map_data.get_height(), " tiles")
	
	# Print seed information if provided
	if seed != null:
		print("Seed: ", seed)
	if detail_seed != null:
		print("Detail Seed: ", detail_seed)
	if territory_seed != null:
		print("Territory Seed: ", territory_seed)
	
	print("------------------------------")
	print("TERRAIN DISTRIBUTION:")
	
	
	# Loop through all terrain types in terrain_database
	for terrain_type in terrain_database.terrain_definitions:
		var percentage = map_data.get_terrain_percentage(terrain_type) * 100
		# Capitalize first letter
		var display_name = terrain_type.substr(0, 1).to_upper() + terrain_type.substr(1)
		print("- ", display_name, ": ", "%.1f" % percentage, "%")
	
	print("------------------------------")
	print("SUBTERRAIN DISTRIBUTION:")
	
	# Loop through all subterrain types
	for subterrain_type in terrain_database.subterrain_definitions:
		# Calculate subterrain percentage
		var percentage = 0.0
		if map_data.has_method("get_subterrain_percentage"):
			percentage = map_data.get_subterrain_percentage(subterrain_type) * 100
		
		# Format subterrain name for display
		var display_name = subterrain_type.replace("_", " ")
		display_name = display_name.substr(0, 1).to_upper() + display_name.substr(1)
		
		print("- ", display_name, ": ", "%.1f" % percentage, "%")
	
	print("------------------------------")
	print("TERRAIN PROPERTIES:")
	print("- Average density: ", "%.2f" % map_data.get_average_density())
	print("- Walkable tiles: ", "%.1f" % (map_data.get_walkable_percentage() * 100), "%")
	
	print("------------------------------")
	print("RESOURCES:")
	var wood_tiles = map_data.find_tiles_with_resource("wood", 0.5)
	var total_tiles = map_data.get_width() * map_data.get_height()
	var wood_percentage = (wood_tiles.size() / float(total_tiles)) * 100
	print("- Wood-rich tiles: ", wood_tiles.size(), " (", "%.1f" % wood_percentage, "%)")
	
	print("------------------------------")
	print("MONSTER TERRITORIES:")
	print("- Monster territories: ", map_data.count_territories_by_type("wolf_pack"))
	print("- Total claimed territory: ", "%.1f" % (map_data.get_territory_coverage() * 100), "% of map")
	print("===============================")

# function to append statistics to a file with time and datestamps
func save_statistics_to_file(): # this shit doesnt work properly
	var timestamp = Time.get_datetime_string_from_system(false, true) # Format: YYYY-MM-DD HH:MM:SS
	var file_path = "user://map_statistics.md"
	
	# Format the statistics as a string
	var statistics = """
Map dimensions: %dx%d tiles
Terrain Seed: %d
Detail Seed: %d

**TERRAIN DISTRIBUTION:**
- Forest: %.1f%%
- Plains: %.1f%%
- Mountain: %.1f%%
- Swamp: %.1f%%
- Water: %.1f%%

**TERRAIN PROPERTIES:**
- Average density: %.2f
- Walkable tiles: %.1f%%

**RESOURCES:**
- Wood-rich tiles: %d (%.1f%%)

**MONSTER TERRITORIES:**
- Monster territories: %d
- Total claimed territory: %.1f%%
""" % [
		map_data.get_width(), map_data.get_height(),
		seed, detail_seed,
		map_data.get_terrain_percentage("forest") * 100,
		map_data.get_terrain_percentage("plains") * 100,
		map_data.get_terrain_percentage("mountain") * 100,
		map_data.get_terrain_percentage("swamp") * 100,
		map_data.get_terrain_percentage("river") * 100,
		map_data.get_average_density(),
		map_data.get_walkable_percentage() * 100,
		map_data.find_tiles_with_resource("wood", 0.5).size(),
		map_data.find_tiles_with_resource("wood", 0.5).size() / float(map_data.get_width() * map_data.get_height()) * 100,
		map_data.count_territories_by_type("wolf_pack"),
		map_data.get_territory_coverage() * 100
	]
	
	# Open the file in append mode
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file == null:
		print("Error opening file: ", FileAccess.get_open_error())
		return
	file.seek_end()
	if FileAccess.file_exists(file_path):
		file = FileAccess.open(file_path, FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_line("# Celestia Map Generation Statistics")
		file.store_line("")
	
	# Write the statistics with a header and timestamp
	file.store_line("## Map Statistics - " + timestamp)
	file.store_line(statistics)
	file.store_line("---")
	file.store_line("")
	file.close()
	
	print("Statistics saved to " + file_path)
