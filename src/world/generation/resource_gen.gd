class_name ResourceGenerator
extends Node

var map_data: MapData
var resource_db: ResourceDatabase
var noise_gen: NoiseGenerator # Reuse existing NoiseGenerator
var resource_seed: int

func _init(map_data_ref, resource_db_ref, noise_generator_ref, main_seed):
	map_data = map_data_ref
	resource_db = resource_db_ref
	noise_gen = noise_generator_ref # Use existing NoiseGenerator
	resource_seed = main_seed * 7919 # Still derive a unique seed for resource variation
	
func generate_resources():
	for resource_id in resource_db.resources:
		generate_specific_resource(resource_id)
	
	print("Resource generation complete")

func generate_specific_resource(resource_id):
	var resource_data = resource_db.get_resource(resource_id)
	
	# Track statistics for debugging
	var placed_count = 0
	var total_amount = 0
	
	# Place resources based on terrain type and noise value
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var tile = map_data.get_tile(Vector2i(x, y))
			
			# Skip if tile already has a resource
			if tile.has_resource():
				continue
				
			# Skip if terrain type doesn't match required types
			if not tile.terrain_type in resource_data.terrain_type:
				continue
			
			# CHANGE: Only place resources on matching subterrains
			if tile.terrain_subtype in resource_data.terrain_subtype:
				# Determine resource amount (with some variety)
				# Use detail noise for variety in resource amounts
				var noise_value = noise_gen.get_detail_noise(x + resource_seed, y + resource_id.hash() % 10000)
				# Normalize to 0-1 range (FastNoiseLite returns -1 to 1)
				noise_value = (noise_value + 1) * 0.5
				
				var base_amount = resource_data.cluster_size
				var variance = noise_value * 2 # Higher noise value = more resources
				var amount = round(base_amount * variance)
				amount = clamp(amount, resource_data.yield_amount[0], resource_data.yield_amount[1])
				
				# Apply territory penalty to amount if in monster territory
				if tile.territory_owner != "":
					amount = max(1, floor(amount * 1.0)) # Reduce by 30% but ensure at least 1 currently disabled
				
				# Initialize resources dictionary if needed
				if not "resources" in tile:
					tile.resources = {}
				
				# Assign resource to tile
				tile.resources[resource_id] = amount
				
				placed_count += 1
				total_amount += amount
