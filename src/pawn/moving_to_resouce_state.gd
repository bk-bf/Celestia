class_name MovingToResourceState
extends PawnState

func enter():
	# Start moving to the resource
	pawn.move_to(pawn.current_job.target_position)
	# Set animation to walking
	
func update(delta):
	# Debug the distance to target
	if pawn.current_job and pawn.current_job.target_position:
		var current_pos = pawn.current_tile_position
		var target_pos = pawn.current_job.target_position
		var distance = current_pos.distance_to(target_pos)
		
		# Only transition to Harvesting when we've actually reached the destination
		if distance < 1.5 and pawn.has_reached_destination:
			print("Reached resource, changing to Harvesting state")
			state_machine.change_state("Harvesting")
	
	# Check if path is blocked or job was canceled
	if pawn.path_blocked or pawn.current_job == null:
		state_machine.change_state("Idle")
