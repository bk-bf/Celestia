class_name Pawn
extends Node2D

# Core attributes
var strength: int = 5
var dexterity: int = 5
var intelligence: int = 5

# Basic identification
var pawn_name: String = "Unnamed"
var pawn_id: int = 0

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

# References
var map_data = MapDataManager.map_data # autoload/singleton for Resource
var terrain_db = TerrainDatabase.new() # Reference to terrain database
var sprite_renderer: SpriteRenderer

# pawn inventory
var inventory = Inventory.new()
var max_carry_weight = 50 # Default value
var current_carry_weight = 0

# state machine
var state_machine
var current_job = null
var harvesting_speed = 1.0
var harvest_time = 0.0
var harvest_progress = 0.0
var progress_bar
var harvesting_target = null
var has_reached_destination = false

# Visual representation
var sprite: Sprite2D

func _init(id: int, start_position: Vector2i, map_reference):
	pawn_id = id
	current_tile_position = start_position
	map_data = map_reference
	
	# Use the existing conversion function
	position = map_data.grid_to_map(start_position)
	#print(map_data.map_to_grid(position))
	
	# Initialize terrain movement multipliers from TerrainDatabase
	initialize_movement_multipliers()

	# Initialize the sprite renderer
	sprite_renderer = SpriteRenderer.new(false) # Use basic sprite for now
	sprite_renderer.set_texture("res://assets/tiles/pawn_placeholder.png")
	add_child(sprite_renderer)
	

func initialize_movement_multipliers():
	# Populate movement multipliers from terrain database
	for terrain_type in terrain_db.terrain_definitions:
		var terrain_def = terrain_db.terrain_definitions[terrain_type]
		if terrain_def.has("movement_cost"):
			terrain_movement_multipliers[terrain_type] = terrain_def.movement_cost
		else:
			# Default value if not specified
			terrain_movement_multipliers[terrain_type] = 1.0

func _ready():
	# Initialize pathfinder
	pathfinder = Pathfinder.new(map_data.terrain_grid)
	
	# Calculate max carrying capacity based on strength
	max_carry_weight = 30 + (strength * 5) # Simple formula, adjust as needed
	
	# Calculate harvesting speed based on attributes
	# For example, dexterity could affect harvesting speed
	harvesting_speed = 1.0 + (dexterity * 0.1) # Simple formula, adjust as needed
	 
	 # Create progress bar
	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.max_value = 1
	progress_bar.value = 0
	progress_bar.size = Vector2(50, 10)
	progress_bar.position = Vector2(-25, -40)
	progress_bar.visible = false
	add_child(progress_bar)
	print("Progress bar added:", progress_bar != null)
	print("Progress bar parent:", progress_bar.get_parent() if progress_bar else "None")
	
	# Set up state machine
	state_machine = PawnStateMachine.new(self)
	add_child(state_machine)
	print("Added the State Machine...")
	
	# Add states
	state_machine.add_state("Idle", IdleState.new())
	state_machine.add_state("MovingToResource", MovingToResourceState.new())
	state_machine.add_state("Harvesting", HarvestingState.new())
	print("States registered:", state_machine.states.keys())
	
	# Set initial state
	state_machine.change_state("Idle")

	# debug
	print("Pawn " + str(pawn_id) + " ready called")
	print("Sprite exists: " + str(sprite_renderer.sprite != null))

	#sprite.scale = Vector2(2, 2) # Adjust based on your art size
	# Set up initial appearance
	update_visual()

# Assign a harvesting job to this pawn
func assign_harvesting_job(positions, resource_type, amount, time):
	current_job = HarvestingJob.new(positions, resource_type, amount, time)
	# State machine will handle the transition to MovingToResource

func _process(delta):
	# Handle movement and other per-frame updates
	if is_moving:
		move_toward_target(delta)


func set_selected(selected: bool):
	is_selected = selected
	update_visual()

# Update the pawn's visual appearance
func update_visual():
	if is_selected:
		sprite_renderer.modulate = Color(1.5, 1.5, 1.5)
	else:
		sprite_renderer.modulate = Color(1, 1, 1)


# Generate random attributes within a range
func generate_random_attributes(min_value: int = 3, max_value: int = 8):
	strength = randi() % (max_value - min_value + 1) + min_value
	dexterity = randi() % (max_value - min_value + 1) + min_value
	intelligence = randi() % (max_value - min_value + 1) + min_value

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

# Add these functions to your Pawn class

# Start moving to a target position
func move_to(target_position: Vector2i) -> bool:
	# Stop any current movement
	is_moving = false
	movement_path.clear()
	
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
	
	# Calculate world position of the next tile
	var next_position = map_data.grid_to_map(next_tile_pos)
	
	# Get terrain type for movement speed calculation
	var terrain_type = map_data.get_tile(next_tile_pos).terrain_type
	var speed_multiplier = 1.0
	if terrain_type in terrain_movement_multipliers:
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
	# Base capacity plus strength bonus
	return 50.0 + (strength * 10)

func calculate_melee_damage() -> float:
	# Base damage plus strength bonus
	return 5.0 + calculate_attribute_bonus(strength) * 2.0

# Dexterity affects movement speed and ranged accuracy
func get_movement_speed() -> float:
	# Base speed modified by dexterity
	return movement_speed * (1.0 + calculate_attribute_bonus(dexterity) * 0.1)

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
		progress_bar.value = 0
		progress_bar.visible = false
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
