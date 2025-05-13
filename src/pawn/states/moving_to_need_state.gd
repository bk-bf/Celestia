class_name MovingToNeedState
extends PawnState

var state_name: String
var target_state = "" # The state to transition to once reached (Eating or Sleeping)

func _init():
	state_name = "MovingToNeed"


func enter():
	# Safety check - make sure we have a job
	if not pawn.current_job:
		print("MovingToNeedState: No job assigned! Returning to Idle.")
		state_machine.change_state("Idle")
		return
		
	# Determine which need we're addressing and set the target state
	if pawn.current_job.type == "eating":
		target_state = "Eating"
	elif pawn.current_job.type == "sleeping":
		target_state = "Sleeping"
	else:
		print("Unknown need type in MovingToNeedState")
		state_machine.change_state("Idle")
		return
	
	# Get the target position from the job
	var target_position = pawn.current_job.target_position
	
	# First check if pawn is already adjacent to the target
	if is_adjacent_to_target(pawn.current_tile_position, target_position):
		print("Already adjacent to target, changing to " + target_state)
		state_machine.change_state(target_state)
		return
	
	# Find an adjacent walkable tile
	var adjacent_position = find_adjacent_walkable_tile(target_position)
	
	# Calculate path to the adjacent position
	var path = pawn.pathfinder.find_path(pawn.current_tile_position, adjacent_position)

	if path.size() > 0:
		# Set up the pawn's movement variables
		pawn.movement_path = path
		pawn.current_path_index = 1 # Skip the first point (current position)
		pawn.is_moving = true
		pawn.has_reached_destination = false
		print("Pawn " + str(pawn.pawn_id) + " moving to " + target_state.to_lower() + " location")
	else:
		# If no path found, cancel the job and go back to need state
		print("No path found to " + target_state.to_lower() + " location!")
		pawn.current_job = null
		
		# Return to appropriate need state instead of Idle
		if target_state == "Eating":
			state_machine.change_state("Idle") # Don't go back to Hungry to prevent cycles
		elif target_state == "Sleeping":
			state_machine.change_state("Idle") # Don't go back to Tired to prevent cycles
		else:
			state_machine.change_state("Idle")


# code duplication in MovingToResourceState, has to be extracted to a utils file eventually
func find_adjacent_walkable_tile(target_position):
	# Check all 8 adjacent tiles
	var directions = [
		Vector2i(1, 0), # Right
		Vector2i(-1, 0), # Left
		Vector2i(0, 1), # Down
		Vector2i(0, -1), # Up
		Vector2i(1, 1), # Down-Right
		Vector2i(-1, 1), # Down-Left
		Vector2i(1, -1), # Up-Right
		Vector2i(-1, -1) # Up-Left
	]
	
	# Try each direction
	for dir in directions:
		var adjacent_pos = target_position + dir
		var tile = pawn.map_data.get_tile(adjacent_pos)
		
		# Check if the tile is walkable
		if tile and tile.walkable:
			return adjacent_pos
	
	# If no walkable adjacent tile found, return the original position as fallback
	return target_position

# code duplication in MovingToResourceState, has to be extracted to a utils file eventually
# Helper function to check if pawn is already adjacent to the target
func is_adjacent_to_target(pawn_pos, target_pos):
	# Check if the positions are adjacent (including diagonals)
	var dx = abs(pawn_pos.x - target_pos.x)
	var dy = abs(pawn_pos.y - target_pos.y)
	return dx <= 1 and dy <= 1 and (dx + dy > 0)

# Helper function to check if pawn is already adjacent to the resource
# code duplication aahhhh!!
func is_adjacent_to_resource(pawn_pos, resource_pos):
	# Check if the positions are adjacent (including diagonals)
	var dx = abs(pawn_pos.x - resource_pos.x)
	var dy = abs(pawn_pos.y - resource_pos.y)
	return dx <= 1 and dy <= 1 and (dx + dy > 0)


func update(delta):
	# Safety check
	if not pawn.current_job:
		state_machine.change_state("Idle")
		return
		
	# Debug the distance to target
	if pawn.current_job and pawn.current_job.target_position:
		var current_pos = pawn.current_tile_position
		var target_pos = pawn.current_job.target_position
		var distance = current_pos.distance_to(target_pos)
		
		# Transition to target state when we've reached the destination
		if distance < 1.5 and pawn.has_reached_destination:
			print("Reached target, changing to " + target_state)
			state_machine.change_state(target_state)
	
	# Check if path is blocked or job was canceled
	if pawn.path_blocked or pawn.current_job == null:
		state_machine.change_state("Idle")
