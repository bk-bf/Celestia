extends Node
class_name MapStatistics

var map_data: MapData
@export var base_seed: int = 0 # If left as 0, a random seed will be used
@export var detail_seed: int = 0 # If left as 0, a random seed will be used
@export var territory_seed: int = 0

# Function to print statistics about a map
# Get monster types from database
static func print_map_statistics(map_data, terrain_database, resource_db = null, base_seed = null, detail_seed = null, territory_seed = null):
	print("\n=== CELESTIA MAP STATISTICS ===")
	print("Map dimensions: ", map_data.get_width(), "x", map_data.get_height(), " tiles")
	
	# Print seed information if provided
	if base_seed != null:
		print("Seed: ", base_seed)
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
	if resource_db:
		var resource_stats = {}
		
		# Collect resource statistics
		for resource_id in resource_db.resources:
			var locations = 0
			var total_amount = 0
			
			for y in range(map_data.get_height()):
				for x in range(map_data.get_width()):
					var tile = map_data.get_tile(Vector2i(x, y))
					if "resources" in tile and resource_id in tile.resources:
						locations += 1
						total_amount += tile.resources[resource_id]
			
			resource_stats[resource_id] = {
				"locations": locations,
				"total_amount": total_amount
			}
			
			# Print statistics for each resource
			print("Generated %s: %d locations, %d total units" % [resource_id, locations, total_amount])
			
			# Calculate percentage of map covered by this resource
			var total_tiles = map_data.get_width() * map_data.get_height()
			var coverage_percentage = (locations / float(total_tiles)) * 100
			print("- %s coverage: %.1f%%" % [resource_id.capitalize(), coverage_percentage])
	else:
		print("No resource database provided.")

	print("------------------------------")
	print("MONSTER TERRITORIES:")
	var territory_database = TerritoryDatabase.new() # Add monsters database
	var available_monster_types = territory_database.get_monster_types()
	print("Post-processing territories...")
	print("Removed " + str(map_data.cleanup_count) + " territories from non-preferred terrain")
	print("- Generated " + str(available_monster_types.size()) + " monster territories")
	print("- Total claimed territory: ", "%.1f" % (map_data.get_territory_coverage() * 100), "% of map")
	print("===============================")
