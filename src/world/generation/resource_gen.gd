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
	
	# Set up random number generator with the resource seed
	var rng = RandomNumberGenerator.new()
	rng.seed = resource_seed + resource_id.hash()
	
	# Place resources based on terrain type and noise value
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var tile = map_data.get_tile(Vector2i(x, y))
			
			# Skip if tile already has a resource
			if tile.has_resource():
				continue
				
			# Skip if terrain type doesn't match required types
			if not tile.terrain_subtype in resource_data.terrain_subtype:
				continue
			
			# Only place resources on matching subterrains
			if tile.terrain_subtype in resource_data.terrain_subtype:
				# Get the resource amount range from the resource definition
				var min_amount = resource_data.resource_amount[0]
				var max_amount = resource_data.resource_amount[1]
				
				# Generate a random amount within the range
				var amount = rng.randi_range(min_amount, max_amount)
				
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
