class_name HarvestingState
extends PawnState

var last_logged_percentage = -10 # Start at -10 to ensure 0% is logged
var has_logged_start = false

func enter():
	# Play harvesting animation
	# Show progress bar
	print('Entered HarvestingState')
	
func update(delta):
	# If job was canceled
	if pawn.current_job == null:
		state_machine.change_state("Idle")
		has_logged_start = false
		return
	
	# Get work speed modifier from traits
	var work_speed_modifier = pawn.get_work_speed()
	
	# Progress the harvesting with trait modifications
	pawn.current_job.progress += delta * pawn.harvesting_speed * work_speed_modifier / pawn.current_job.time_to_harvest
	
	# Log only at the beginning (0%)
	if not has_logged_start:
		print('Harvesting progress: 0%')
		has_logged_start = true
	
	# Check if harvesting is complete
	if pawn.current_job.is_complete():
		# Log completion (100%)
		print('Harvesting progress: 100%')
		
		# Calculate how much to harvest
		var harvest_amount = pawn.current_job.calculate_harvest_amount()
		
		# Debug prints
		print("Target position: ", pawn.current_job.target_position)
		var tile_resources = pawn.map_data.get_resources_at(pawn.current_job.target_position)
		print("Resources at tile before harvest: ", tile_resources)
		
		var amount_on_tile = 0
		if tile_resources and pawn.current_job.resource_type in tile_resources:
			amount_on_tile = tile_resources[pawn.current_job.resource_type]
			print("Amount of " + pawn.current_job.resource_type + " on tile: ", amount_on_tile)
		else:
			print("No " + pawn.current_job.resource_type + " found on tile")
		
		# Log the harvesting event
		if DebugLogger.instance:
			DebugLogger.instance.log_resource_harvested(
				pawn.name,
				pawn.current_job.resource_type,
				harvest_amount,
				pawn.current_job.target_position
			)
		
		# Add resources to inventory
		pawn.inventory.add_item(pawn.current_job.resource_type, harvest_amount)
		
		# Update the resource on the map
		print("Attempting to reduce resource by: ", amount_on_tile)
		pawn.map_data.reduce_resource_at(pawn.current_job.target_position, amount_on_tile)
		
		# Verify resource was removed
		tile_resources = pawn.map_data.get_resources_at(pawn.current_job.target_position)
		print("Resources at tile after harvest: ", tile_resources)
		
		# Reset for next job
		has_logged_start = false
		
		# Job is done
		pawn.current_job = null
		state_machine.change_state("Idle")
