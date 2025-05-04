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

# References
var map_data = null # Will hold reference to your map
var terrain_db = TerrainDatabase.new() # Reference to terrain database

# Visual representation
var sprite: Sprite2D

func _init(id: int, start_position: Vector2i, map_reference):
	pawn_id = id
	current_tile_position = start_position
	map_data = map_reference
	
	# Use the existing conversion function
	position = map_data.grid_to_map(start_position)
	
	# Initialize the sprite
	sprite = Sprite2D.new()
	sprite.texture = preload("res://assets/tiles/pawn_placeholder.png") # Create this placeholder image
	add_child(sprite)
	
	# Initialize terrain movement multipliers from TerrainDatabase
	initialize_movement_multipliers()

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
	
	# Set up initial appearance
	update_visual()

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
		# Add selection indicator (e.g., change color or add outline)
		modulate = Color(1.5, 1.5, 1.5) # Brighten the sprite
	else:
		modulate = Color(1, 1, 1) # Normal color

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
		is_moving = false
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
			print("Reached destination")
			
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

# Add these functions to your Pawn class

# Start harvesting a resource at the target position
func harvest_resource(target_position: Vector2i) -> bool:
	# First, move to the position adjacent to the resource
	# Find an adjacent tile that is walkable
	var adjacent_positions = [
		Vector2i(target_position.x + 1, target_position.y),
		Vector2i(target_position.x - 1, target_position.y),
		Vector2i(target_position.x, target_position.y + 1),
		Vector2i(target_position.x, target_position.y - 1)
	]
	
	var harvest_position = null
	for pos in adjacent_positions:
		if map_data.is_tile_walkable(pos.x, pos.y):
			harvest_position = pos
			break
	
	if harvest_position == null:
		print("No accessible position adjacent to resource")
		return false
	
	# Move to the position
	if current_tile_position != harvest_position:
		move_to(harvest_position)
		# We'll need to wait until movement is complete before harvesting
		# This would be handled by a state machine in a more complete implementation
		return true
	
	# Get the resource information
	var resource_tile = map_data.get_tile(target_position.x, target_position.y)
	if resource_tile.resource_type == null or resource_tile.resource_amount <= 0:
		print("No resource to harvest!")
		return false
	
	# Calculate harvest speed based on strength (for now)
	var harvest_speed = 1.0 + calculate_attribute_bonus(strength) * 0.2
	
	# In a complete implementation, you would start a timer here
	# and perform the actual harvesting when the timer completes
	print("Starting to harvest with speed multiplier: " + str(harvest_speed))
	
	# For now, just instantly harvest one unit
	resource_tile.resource_amount -= 1
	
	# If depleted, remove resource from tile
	if resource_tile.resource_amount <= 0:
		resource_tile.resource_type = null
		# Update tile appearance would happen here
	
	print("Harvested resource!")
	return true
