class_name HungryState
extends PawnState

var state_name: String

# Track if we're already searching for food to prevent cycles
var is_searching_for_food = false
var food_search_cooldown = 3.0
var last_search_time = 0.0

# Add a flag to track if we've already printed the message
var message_printed = false

func _init():
	state_name = "Hungry"

func enter():
	# Only print and search for food if we haven't recently
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if current_time - last_search_time > food_search_cooldown:
		print("Pawn " + str(pawn.pawn_id) + " is hungry and looking for food")
		last_search_time = current_time
		is_searching_for_food = true
		find_food()
	else:
		# If we recently searched, just wait in this state
		await get_tree().create_timer(0.5).timeout
		check_needs_state()

func exit():
	is_searching_for_food = false

func find_food():
	# Find the nearest food source
	var food_position = find_nearest_food_source()
	
	if food_position and is_valid_food_position(food_position):
		# Create an eating job
		pawn.current_job = EatingJob.new(food_position, "food", 1, 2.0)
		pawn.current_job.assigned_pawn = pawn
		
		# Change to MovingToNeed state
		state_machine.change_state("MovingToNeed")
	else:
		print("No valid food found for Pawn " + str(pawn.pawn_id) + "! Waiting...")
		# Stay in hungry state but don't immediately search again
		is_searching_for_food = false
		# Check again after a cooldown
		await get_tree().create_timer(food_search_cooldown).timeout
		check_needs_state()

# Check if the position is valid and accessible
func is_valid_food_position(pos):
	# Check if position is within map bounds
	if not pawn.map_data.is_within_bounds_map(pos):
		return false
		
	# Check if there's a path to this position
	var adjacent_pos = find_adjacent_walkable_tile(pos)
	var path = pawn.pathfinder.find_path(pawn.current_tile_position, adjacent_pos)
	return path.size() > 0

# Find an adjacent walkable tile to the target
# has to be centralized we are duplicating this all over the place
func find_adjacent_walkable_tile(target_position):
	# Check all 8 adjacent tiles
	var directions = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)
	]
	
	for dir in directions:
		var adjacent_pos = target_position + dir
		var tile = pawn.map_data.get_tile(adjacent_pos)
		if tile and tile.walkable:
			return adjacent_pos
	
	return target_position


func find_nearest_food_source():
	# For now, return a placeholder position
	# In a real implementation, you'd search the map for food sources
	return Vector2i(10, 10) # Placeholder

# Check if we should change states based on needs
func check_needs_state():
	# Only change state if we're still in the HungryState
	if state_machine.current_state == "Hungry":
		# If hunger is no longer critical, go back to idle
		if not pawn.needs["hunger"].is_critical():
			state_machine.change_state("Idle")
		# Otherwise try searching for food again if cooldown has passed
		elif not is_searching_for_food:
			enter()
