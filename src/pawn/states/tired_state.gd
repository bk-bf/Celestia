class_name TiredState
extends PawnState

var state_name: String

# Track if we're already searching for food to prevent cycles
var is_searching_for_rest = false
var rest_search_cooldown = 3.0
var last_search_time = 0.0

# Add a flag to track if we've already printed the message
var message_printed = false

func _init():
	state_name = "Tired" # This should be a property assignment, not a local variable

func enter():
	# Only print and search for rest if we haven't recently
	var current_time = Time.get_ticks_msec() / 1000.0

	if current_time - last_search_time > rest_search_cooldown:
		print("Pawn " + str(pawn.pawn_id) + " is tired and looking for a place to rest")
		last_search_time = current_time
		is_searching_for_rest = true
		find_rest_place()
	else:
		# If we recently searched, just wait in this state
		await get_tree().create_timer(0.5).timeout
		check_needs_state()

func find_rest_place():
	# Find the nearest rest place
	var rest_position = find_nearest_rest_place()
	
	if rest_position:
		# Create a sleeping job
		pawn.current_job = SleepingJob.new(rest_position, "simple_spot", 1, 5.0)
		
		# Change to MovingToNeed state
		state_machine.change_state("MovingToNeed")
	else:
		print("No rest place found!")
		state_machine.change_state("Idle")

func find_nearest_rest_place():
	# This would search the map for rest places
	# For now, return a placeholder position
	# In the future, this would use your map data to find actual beds
	return Vector2i(15, 15) # Placeholder

# Check if we should change states based on needs
# duplicate code aaaaajhhh
func check_needs_state():
	# Only change state if we're still in the HungryState
	if state_machine.current_state == "Tired":
		# If sleep is no longer critical, go back to idle
		if not pawn.needs["rest"].is_critical():
			state_machine.change_state("Idle")
		# Otherwise try searching for food again if cooldown has passed
		elif not is_searching_for_rest:
			enter()
