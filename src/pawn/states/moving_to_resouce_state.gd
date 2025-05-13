class_name MovingToResourceState
extends PawnState

func enter():
	# Get the resource position from the job
	var resource_position = pawn.current_job.target_position
	
	# First check if pawn is already adjacent to the resource
	if is_adjacent_to_resource(pawn.current_tile_position, resource_position):
		print("Already adjacent to resource, changing to Harvesting state")
		state_machine.change_state("Harvesting")
		return
	
	# Find an adjacent walkable tile instead of the resource tile itself
	var adjacent_position = find_adjacent_walkable_tile(resource_position)
	
	# Calculate path to the adjacent position
	var path = pawn.pathfinder.find_path(pawn.current_tile_position, adjacent_position)

	if path.size() > 0:
		# Set up the pawn's movement variables
		pawn.movement_path = path
		pawn.current_path_index = 1 # Skip the first point (current position)
		pawn.is_moving = true
		pawn.has_reached_destination = false
	else:
		# If no path found, cancel the job
		pawn.current_job = null
		state_machine.change_state("Idle")

# Helper function to check if pawn is already adjacent to the resource
func is_adjacent_to_resource(pawn_pos, resource_pos):
	# Check if the positions are adjacent (including diagonals)
	var dx = abs(pawn_pos.x - resource_pos.x)
	var dy = abs(pawn_pos.y - resource_pos.y)
	return dx <= 1 and dy <= 1 and (dx + dy > 0)

func find_adjacent_walkable_tile(target_position):
	# Collect all walkable adjacent tiles
	var valid_positions = []
	var directions = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)
	]
	
	for dir in directions:
		var adjacent_pos = target_position + dir
		var tile = pawn.map_data.get_tile(adjacent_pos)
		if tile and tile.walkable:
			valid_positions.append(adjacent_pos)
	
	# If no valid positions, return original target
	if valid_positions.size() == 0:
		return target_position
	
	# Find position with shortest actual path
	var best_position = valid_positions[0]
	var shortest_path_length = INF
	
	for pos in valid_positions:
		var path = pawn.pathfinder.find_path(pawn.current_tile_position, pos)
		if path.size() > 0 and path.size() < shortest_path_length:
			shortest_path_length = path.size()
			best_position = pos
	
	return best_position


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
