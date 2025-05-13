class_name Pawn
extends Node2D

# Core attributes
@export var strength: int = 5
@export var dexterity: int = 5
@export var intelligence: int = 5

# Basic identification
var pawn_id: int = 0
var pawn_name = ""
var pawn_gender = "male"


# List of traits this pawn has
var traits = []

# Needs system
var needs = {}
var last_needs_check_time = 0.0
var needs_check_cooldown = 1.0 # Check needs once per second
signal need_changed(need_name, old_value, new_value, state)

# Position and movement
var current_tile_position: Vector2i = Vector2i(0, 0)
var target_tile_position: Vector2i = Vector2i(0, 0)
var is_moving: bool = false
var movement_speed: float = 1.0
var terrain_movement_multipliers = {}
var is_selected: bool = false
var movement_path: Array = []
var current_path_index: int = 0
var pathfinder = null
var path_blocked = false

var appearance_id: int = 0 # For storing the pawn's visual appearance ID
var previous_position: Vector2i = Vector2i(-1, -1) # For tracking previous position


# References
var map_data: MapData = null # Will be set when map_data_loaded signal is received
var terrain_db: TerrainDatabase = DatabaseManager.terrain_database # Reference to terrain database
var sprite_renderer = SpriteRenderer.new()


# pawn inventory
var inventory = Inventory.new()
var max_carry_weight = 50 # Default value
var current_carry_weight = 0

# constants
const MIN_ATTRIBUTE_VALUE := 3
const MAX_ATTRIBUTE_VALUE := 8
const BASE_MOVEMENT_SPEED := 1.0
const BASE_CARRY_WEIGHT := 50.0
const TILE_REACH_THRESHOLD := 2.0

# state machine
var state_machine
var current_job = null
var harvesting_speed = 1.0
var harvest_time = 0.0
var harvest_progress = 0.0
var progress_bar = false
var harvesting_target = null
var has_reached_destination = false

# signal declarations for state changes
signal state_changed(old_state: String, new_state: String)
signal attribute_changed(attribute: String, old_value: int, new_value: int)
signal resource_harvested(resource_id: String, amount: int)

# Visual representation
var sprite: Sprite2D
var appearance_color: Color


func _init(id: int, start_position: Vector2i, map_reference):
	pawn_id = id
	current_tile_position = start_position
	
	# SpriteRenderer has to be referenced like this, might be useful to look into migrating to DatabaseManager
	sprite_renderer = SpriteRenderer.new(false)
	sprite_renderer.set_texture("res://assets/tiles/pawns_32x32_sprite.png")
	add_child(sprite_renderer)


	# Initialize terrain movement multipliers from TerrainDatabase
	initialize_movement_multipliers()
	
	
func initialize_movement_multipliers():
	# Populate movement multipliers from terrain and subterrain definitions
	for terrain_type in terrain_db.terrain_definitions:
		var terrain_def = terrain_db.terrain_definitions[terrain_type]
		if terrain_def.has("movement_cost"):
			terrain_movement_multipliers[terrain_type] = terrain_def.movement_cost
		else:
			# Default value if not specified
			terrain_movement_multipliers[terrain_type] = 1.0

	for subterrain_type in terrain_db.subterrain_definitions:
		var subterrain_def = terrain_db.subterrain_definitions[subterrain_type]
		if subterrain_def.has("movement_cost"):
			terrain_movement_multipliers[subterrain_type] = subterrain_def.movement_cost
		else:
			# Default value if not specified
			terrain_movement_multipliers[subterrain_type] = 1.0

func _ready():
	# Connect to the map_data_loaded signal
	DatabaseManager.connect("map_data_loaded", _on_map_data_loaded)
	# Randomly assign gender during initialization
	var name_data = DatabaseManager.get_random_name()
	pawn_name = name_data.name
	pawn_gender = name_data.gender
	
	# Calculate max carrying capacity based on strength
	max_carry_weight = 30 + (strength * 5) # Simple formula, adjust as needed
	
	# Calculate harvesting speed based on attributes
	harvesting_speed = 1.0 + (dexterity * 0.1) # Simple formula, adjust as needed
	
	# For testing, assign a random trait
	assign_random_traits()
	
	# Initialize needs
	initialize_needs()
	
	# Set up state machine
	state_machine = PawnStateMachine.new(self)
	add_child(state_machine)
	print("Added the State Machine...")
	 
	# Add states
	state_machine.add_state("Idle", IdleState.new())
	state_machine.add_state("MovingToResource", MovingToResourceState.new())
	state_machine.add_state("Harvesting", HarvestingState.new())
	state_machine.add_state("MovingToNeed", MovingToNeedState.new())
	state_machine.add_state("Hungry", HungryState.new())
	state_machine.add_state("Tired", TiredState.new())
	state_machine.add_state("Eating", EatingState.new())
	state_machine.add_state("Sleeping", SleepingState.new())
	
	print("States registered:", state_machine.states.keys())
	
	# Set initial state
	state_machine.change_state("Idle")

	# Randomize pawn appearance using the tilesheet
	#appearance_id = sprite_renderer.randomize_appearance_from_sprite()
	appearance_id = sprite_renderer.randomize_appearance_from_tilesheet()
	
	# debug
	print("Pawn " + str(pawn_id) + " ready called with appearance ID: " + str(appearance_id) + " sprite exits: " + str(sprite_renderer.sprite != null))
	update_visual()

func _on_map_data_loaded():
	# Now we can safely access map_data
	map_data = DatabaseManager.map_data
	position = map_data.grid_to_map(current_tile_position)
	
	# Initialize pathfinder now that we have map_data
	pathfinder = Pathfinder.new(map_data.terrain_grid)


func assign_random_traits():
	# Get all available traits
	var all_traits = DatabaseManager.trait_database.traits.keys()
	
	# Determine how many traits to assign (2-5)
	var num_traits = randi() % 4 + 2 # Random number between 2-5
	
	# Make sure we don't try to assign more traits than are available
	num_traits = min(num_traits, all_traits.size())
	
	# Create a temporary copy of the traits array to pick from
	var available_traits = all_traits.duplicate()
	
	# Assign the random traits
	for i in range(num_traits):
		if available_traits.size() > 0:
			# Pick a random trait from the remaining available traits
			var random_index = randi() % available_traits.size()
			var trait_name = available_traits[random_index]
			
			# Add the trait to the pawn
			add_trait(trait_name)
			
			# Remove the trait from available traits to prevent duplicates
			available_traits.remove_at(random_index)
	
	# Print the final traits list for debugging
	print("Pawn assigned traits (" + str(traits.size()) + "): " + str(traits))


func add_trait(trait_name):
	if DatabaseManager.get_trait(trait_name) != null and not traits.has(trait_name):
		traits.append(trait_name)
		#print("Pawn received trait: " + trait_name)


# Check if a condition is met for a trait
func is_condition_met(conditions):
	if conditions.has("time_of_day"):
		# You'll need to implement a day/night system
		var current_time = "day" # Placeholder
		if conditions["time_of_day"] != current_time:
			return false

	if conditions.has("health_percentage_below"):
		# Assuming you have a health system
		var health_percentage = 1.0 # Placeholder
		if health_percentage >= conditions["health_percentage_below"]:
			return false
	
	if conditions.has("same_task_hours"):
		# You'll need to track how long a pawn has been on a task
		var hours_on_task = 0 # Placeholder
		if hours_on_task < conditions["same_task_hours"]:
			return false
	
	return true

# Get modified stat value based on traits
## Calculates the final stat value after applying all trait modifiers
## [param stat_name] The name of the stat to modify
## [param base_value] The starting value before modifications
## Returns: The final modified value
func get_modified_stat(stat_name, base_value):
	var trait_database: TraitDatabase = DatabaseManager.trait_database
	var modified_value = base_value
	
	for trait_name in traits:
		var trait_data = trait_database.get_trait(trait_name)
		if trait_data == null: # Check the returned data, not a property on trait_database
			continue
			
		# Check if trait affects this stat
		if trait_data.has("effects") and trait_data["effects"].has(stat_name):
			# Check if conditions are met
			if trait_data.has("conditions") and is_condition_met(trait_data["conditions"]):
				modified_value *= trait_data["effects"][stat_name]
	
	return modified_value


# Assign a harvesting job to this pawn
# move this to HarvestingJob?
func assign_harvesting_job(positions, resource_type, amount, time):
	current_job = HarvestingJob.new(positions, resource_type, amount, time)
	# State machine will handle the transition to MovingToResource

func _process(delta):
	# Handle movement and other per-frame updates
	if is_moving:
		move_toward_target(delta)
	# Check needs if we're in an idle state, but not too frequently
	var current_time = Time.get_ticks_msec() / 1000.0
	if state_machine.current_state == "Idle" and current_time - last_needs_check_time > needs_check_cooldown:
		last_needs_check_time = current_time
		check_needs()

func check_needs():
	# Check for needs that require attention
	if needs["hunger"].is_critical():
		state_machine.change_state("Hungry")
	elif needs["rest"].is_critical():
		state_machine.change_state("Tired")
	# Only check non-critical needs if we're idle
	elif state_machine.current_state == "Idle":
		if needs["hunger"].needs_attention() and !needs["rest"].is_critical():
			state_machine.change_state("Hungry")
		elif needs["rest"].needs_attention() and !needs["hunger"].is_critical():
			state_machine.change_state("Tired")

func set_selected(selected: bool):
	is_selected = selected
	update_visual()

# Update the pawn's visual appearance
func update_visual():
	if is_selected:
		sprite_renderer.modulate = Color(1.2, 1.2, 1.2)
	else:
		sprite_renderer.modulate = Color(1, 1, 1)


# Generate random attributes within a range
func generate_random_attributes():
	strength = randi() % (MAX_ATTRIBUTE_VALUE - MIN_ATTRIBUTE_VALUE + 1) + MIN_ATTRIBUTE_VALUE
	dexterity = randi() % (MAX_ATTRIBUTE_VALUE - MIN_ATTRIBUTE_VALUE + 1) + MIN_ATTRIBUTE_VALUE
	intelligence = randi() % (MAX_ATTRIBUTE_VALUE - MIN_ATTRIBUTE_VALUE + 1) + MIN_ATTRIBUTE_VALUE

# Get an attribute value by name
func get_attribute(attribute_name: String) -> int:
	match attribute_name.to_lower():
		"strength", "str":
			return strength
		"dexterity", "dex":
			return dexterity
		"intelligence", "int":
			return intelligence
		_:
			push_error("Unknown attribute: " + attribute_name)
			return 0

# Modify an attribute (for level ups, injuries, etc.)
func modify_attribute(attribute_name: String, amount: int) -> bool:
		if amount == 0:
			return true # No change needed
			
		if attribute_name.is_empty():
			push_error("Empty attribute name provided")
			return false
	
		match attribute_name.to_lower():
			"strength", "str":
				strength += amount
				return true
			"dexterity", "dex":
				dexterity += amount
				return true
			"intelligence", "int":
				intelligence += amount
				return true
			_:
				push_error("Unknown attribute: " + attribute_name)
				return false
			
# Calculate attribute-based bonuses (returns a value from -2 to +3 typically)
func calculate_attribute_bonus(attribute_value: int) -> int:
	return (attribute_value - 5) / 2 # Simple D&D-like formula


# Start moving to a target position
func move_to(target_position: Vector2i) -> bool:
	# Stop any current movement
	is_moving = false
	movement_path.clear()

	# error checking	
	if not pathfinder:
		push_error("Pathfinder not initialized")
		return false
		
	if not map_data:
		push_error("Map data not initialized")
		return false

	# Use pathfinder to find a path
	movement_path = pathfinder.find_path(current_tile_position, target_position)
	
	if movement_path.size() <= 1: # Path only contains current position or is empty
		print("No valid path found")
		return false
	
	# Start moving
	current_path_index = 1 # Skip the first point (current position)
	is_moving = true
	return true


# Called in _process to handle movement along path
func move_toward_target(delta):
	if current_path_index >= movement_path.size():
		# We've reached the end of the path
		is_moving = false #
		has_reached_destination = true
		print("Reached destination, has_reached_destination set to:", has_reached_destination)
		return
	
	# Get the next tile in the path
	var next_tile_pos = movement_path[current_path_index]
	
	# Calculate map position of the next tile
	var next_position = map_data.grid_to_map(next_tile_pos)
	
	# Get terrain type for movement speed calculation
	var terrain_type = map_data.get_tile(next_tile_pos).terrain_type
	var subterrain_type = map_data.get_tile(next_tile_pos).terrain_subtype if map_data.get_tile(next_tile_pos) else null


	var speed_multiplier = 1.0
	
	# Check if subterrain_type has a movement cost and use it if available
	if subterrain_type in terrain_movement_multipliers:
		speed_multiplier = terrain_movement_multipliers[subterrain_type]
	elif terrain_type in terrain_movement_multipliers:
		speed_multiplier = terrain_movement_multipliers[terrain_type]
	
	# Calculate adjusted speed based on dexterity and terrain
	var adjusted_speed = movement_speed * (1.0 + calculate_attribute_bonus(dexterity) * 0.1)
	adjusted_speed /= speed_multiplier # Apply terrain multiplier (higher = slower)
	
	# Move toward the next position
	var direction = (next_position - position).normalized()
	position += direction * adjusted_speed * delta * 60 # Multiply by 60 for consistent speed

	# Check if we've reached the next tile
	if position.distance_to(next_position) < 2.0: # Small threshold
		# Update current tile position
		current_tile_position = next_tile_pos
		position = next_position # Snap to grid
		current_path_index += 1

		 # Check if we've reached the end of the path
		if current_path_index >= movement_path.size():
			is_moving = false
			has_reached_destination = true
			print("Reached destination")
		else:
			has_reached_destination = false # Reset when moving

	if current_path_index < movement_path.size():
		var next_tile = map_data.get_tile(next_tile_pos)
		
		if !next_tile.walkable:
			path_blocked = true
			print("Path blocked at position: ", next_tile_pos)
		else:
			path_blocked = false
			
# Strength affects carrying capacity and melee damage
func get_carrying_capacity() -> float:
	return BASE_CARRY_WEIGHT + (strength * 10)
	
func calculate_melee_damage() -> float:
	# Base damage plus strength bonus
	return 5.0 + calculate_attribute_bonus(strength) * 2.0

# Dexterity affects movement speed and ranged accuracy
func get_movement_speed() -> float:
	var base_speed = BASE_MOVEMENT_SPEED * (1.0 + calculate_attribute_bonus(dexterity) * 0.1)
	return get_modified_stat("movement_speed", base_speed)

# Example usage in vision range calculation
func get_vision_range():
	var base_range = 5 + (dexterity * 0.2)
	return get_modified_stat("vision_range", base_range)

# Example usage in damage calculation
func get_melee_damage():
	var base_damage = 10 + (strength * 2)
	return get_modified_stat("melee_damage", base_damage)

# Example usage in work speed calculation
func get_work_speed():
	var base_speed = 1.0 + (dexterity * 0.05)
	return get_modified_stat("work_speed", base_speed)

func calculate_ranged_accuracy() -> float:
	# Base accuracy plus dexterity bonus (percentage)
	return 70.0 + calculate_attribute_bonus(dexterity) * 5.0

# Intelligence affects learning speed and magical abilities
func get_learning_rate() -> float:
	# Base rate plus intelligence bonus
	return 1.0 + calculate_attribute_bonus(intelligence) * 0.2

func calculate_magic_power() -> float:
	# Base power plus intelligence bonus
	return 10.0 + calculate_attribute_bonus(intelligence) * 3.0


func harvest_resource(grid_position: Vector2i, resource_id: String, amount: int):
	print("Pawn " + str(pawn_id) + " attempting to harvest " + resource_id + " at position:", grid_position)
	
	if state_machine.current_state == "Harvesting":
		# Complete current job
		current_job = null
		# Reset progress
		#progress_bar.value = 0
		#progress_bar.visible = false
		# Change to idle first
		state_machine.change_state("Idle")
	
	# Create a new harvesting job
	var job = HarvestingJob.new(
		grid_position,
		resource_id,
		amount,
		2.0 # Default harvest time
	)
	
	# Assign the job to this pawn
	current_job = job
	job.assigned_pawn = self
	
	#print("Created harvesting job for resource:", resource_id)
	#print("Current job is now:", current_job)
	
	# Change state to MovingToResource
	state_machine.change_state("MovingToResource")
	
	return true


func initialize_needs():
	# Create hunger need
	var hunger = HungerNeed.new()
	hunger.pawn = self
	needs["hunger"] = hunger
	add_child(hunger)
	
	# Create rest need
	var rest = RestNeed.new()
	rest.pawn = self
	needs["rest"] = rest
	add_child(rest)
	
	# Connect signals for need monitoring
	for need_name in needs:
		var need = needs[need_name]
		need.connect("value_changed", _on_need_changed)

func _on_need_changed(need_name, old_value, new_value, state):
	emit_signal("need_changed", need_name, old_value, new_value, state)
	
	# Check if we need to change state based on critical needs
	check_needs_state()

func check_needs_state():
	# If we're already in a need-related state, don't interrupt
	if state_machine.current_state in ["Eating", "Sleeping"]:
		return
		
	# Check for critical needs
	if needs["hunger"].is_critical():
		# Transition to hungry state if not already in it
		if state_machine.current_state != "Hungry":
			state_machine.change_state("Hungry")
	elif needs["rest"].is_critical():
		# Transition to tired state if not already in it
		if state_machine.current_state != "Tired":
			state_machine.change_state("Tired")
	# Check for needs that require attention but aren't critical
	elif needs["hunger"].needs_attention():
		# Only change if we're idle
		if state_machine.current_state == "Idle":
			state_machine.change_state("Hungry")
	elif needs["rest"].needs_attention():
		# Only change if we're idle
		if state_machine.current_state == "Idle":
			state_machine.change_state("Tired")
