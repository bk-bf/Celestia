class_name HarvestingState
extends PawnState

func enter():
	# Play harvesting animation
	# Show progress bar
	print('Entered HarvestingState')
	pawn.progress_bar.visible = true

func exit():
	# Hide progress bar
	pawn.progress_bar.visible = false

func update(delta):
	var percentage = int(pawn.current_job.progress * 100)
	print('Harvesting progress: ' + str(percentage), "%" if pawn.current_job else 'No job')
	# If job was canceled
	if pawn.current_job == null:
		state_machine.change_state("Idle")
		return
		
	# Progress the harvesting
	pawn.current_job.progress += delta * pawn.harvesting_speed / pawn.current_job.time_to_harvest
	pawn.progress_bar.value = pawn.current_job.progress
	
	# Check if harvesting is complete
	if pawn.current_job.is_complete():
		# Add resource to inventory
		pawn.inventory.add_item(pawn.current_job.resource_type, 1)
		
		# Update the resource on the map - use the reference already in pawn
		pawn.map_data.reduce_resource_at(pawn.current_job.target_position, 1)
		
		# Job is done
		pawn.current_job = null
		state_machine.change_state("Idle")
