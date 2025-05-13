class_name IdleState
extends PawnState

func enter():
	# Ensure the pawn is visible
	if pawn and pawn.sprite:
		pawn.visible = true
		# force a visibility refresh
		pawn.sprite.visible = true
		pawn.sprite.visible = true
		
		# Reset animations or visuals to idle state
		pawn.modulate = Color(1, 1, 1) # Normal color

		# debug
		print("Entering idle state for pawn " + str(pawn.pawn_id))
		#print("Pawn visible: " + str(pawn.visible))
		#print("Sprite exists: " + str(pawn.sprite != null))
		#print("Sprite visible: " + str(pawn.sprite.visible))

func update(delta):
	# Only print debugging occasionally to avoid spam
	if Engine.get_frames_drawn() % 1800 == 0: # Once every 30 seconds at 60 FPS
		print("IdleState checking for jobs, current job:", pawn.current_job)

	# Check for new jobs or commands
	if pawn.current_job != null:
		print("Job detected in IdleState, type:", pawn.current_job.get_class())
		if pawn.current_job is HarvestingJob:
			print("Harvesting job detected, changing to MovingToResource")
			state_machine.change_state("MovingToResource")
