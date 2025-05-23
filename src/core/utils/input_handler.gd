class_name InputHandler
extends Node2D

# References to other nodes
@onready var map = get_node("../Map")
@onready var main = get_parent()
var pawn_manager = DatabaseManager.pawn_manager
var territory_database = DatabaseManager.territory_database
var terrain_database = DatabaseManager.terrain_database
@export var draw_pathfinder: bool = false

# Pawn selection tracking
var selected_pawn_id = -1
var debug_path = []

func _ready():
	var map_data = DatabaseManager.map_data
	# Wait until map generation is complete
	await get_tree().create_timer(0.5).timeout
	#var map_data = map_data # autoload/singleton for Resource
	print("InputHandler initialized")
	# Get reference to the PawnManager
	pawn_manager = get_node("/root/Game/Main/PawnManager")

func _input(event):
	var map_data = DatabaseManager.map_data

	# if statement to handle all mouse inputs
	if event is InputEventMouseButton and event.pressed:
		var click_position = get_global_mouse_position()
		var grid_coords = map_data.map_to_grid(click_position)

		# Left click with shift held
		if event.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SHIFT):
			handle_shift_click_territory_info(grid_coords)
			get_viewport().set_input_as_handled()

		# Right click with shift held
		elif event.button_index == MOUSE_BUTTON_RIGHT and Input.is_key_pressed(KEY_SHIFT):
			handle_shift_right_click_terrain_info(grid_coords)
			get_viewport().set_input_as_handled()

		# Handle left-click for pawn selection
		elif event.button_index == MOUSE_BUTTON_LEFT:
			handle_pawn_selection(grid_coords)

		# Handle right-click for movement
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			handle_pawn_movement(grid_coords, click_position)

		# Handle middle-click for resource harvesting
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if map_data.is_within_bounds_map(grid_coords):
				print("middle mouse button clicked on map")
				# Check if there's a resource at this position
				var tile = map_data.get_tile(grid_coords)
				print(tile)
				
				if tile and tile.has_resource():
					# Get the first resource type in the dictionary
					var resource_id = tile.resources.keys()[0] if tile.resources.size() > 0 else ""
					var amount = tile.resources[resource_id] if resource_id else 0
					
					print("Resource found:", resource_id, "Amount:", amount)
					
					if resource_id != "" and amount > 0:
						# Use the selected_pawn_id you're already tracking
						if selected_pawn_id != -1:
							var selected_pawn = pawn_manager.get_pawn(selected_pawn_id)
							print("Selected pawn for harvesting:", selected_pawn)

							if selected_pawn:
								# Assign harvesting job to the pawn
								var success = selected_pawn.harvest_resource(grid_coords, resource_id, amount)
								print("Harvest job assignment result:", success)
								# map.map_renderer.highlight_tile(grid_coords, Color(0, 1, 0, 0.3), 0.5)
								get_viewport().set_input_as_handled()
						else:
							print("No pawn selected for harvesting")
				else:
					print("No resources found at this location")

	# if statement to handle all keyboard inputs
	# Add keyboard input handling for mood display
	elif event is InputEventKey and event.pressed:
		# Check for 'M' key press when a pawn is selected
		if event.keycode == KEY_M and event.shift_pressed and selected_pawn_id != -1:
			display_pawn_mood_info()
			get_viewport().set_input_as_handled()
		
		# Check for 'A' key press when a pawn is selected
		elif event.keycode == KEY_A and event.shift_pressed and selected_pawn_id != -1:
			display_pawn_attributes()
			get_viewport().set_input_as_handled()
			
		# Check for 'S' key press when a pawn is selected
		elif event.keycode == KEY_S and event.shift_pressed and selected_pawn_id != -1:
			display_pawn_stats()
			get_viewport().set_input_as_handled()


func handle_pawn_selection(grid_coords):
	# Check if we clicked on a pawn
	var clicked_on_pawn = false
	for pawn in pawn_manager.get_all_pawns():
		if pawn.current_tile_position == grid_coords:
			# Select this pawn
			selected_pawn_id = pawn.pawn_id
			clicked_on_pawn = true
			print("Selected pawn: " + pawn.pawn_name + " gender: " + pawn.pawn_gender)
			print("Pawn traits: ", pawn.traits)
			print("Inventory: ", pawn.inventory.items)
			print("Hunger: ", pawn.needs["hunger"].current_value)
			print("Rest: ", pawn.needs["rest"].current_value)
			
			# Use job_to_string() for better job information
			if pawn.current_job:
				print("Current job: ", pawn.current_job.job_to_string())
			else:
				print("Current job: None")

			# Visual feedback for selection (add highlight)
			pawn.set_selected(true)

			# Deselect other pawns
			for other_pawn in pawn_manager.get_all_pawns():
				if other_pawn.pawn_id != selected_pawn_id:
					other_pawn.set_selected(false)

			break
	# If we didn't click on a pawn, deselect current pawn
	if not clicked_on_pawn:
		if selected_pawn_id != -1:
			var prev_selected = pawn_manager.get_pawn(selected_pawn_id)
			if prev_selected:
				prev_selected.set_selected(false)
		selected_pawn_id = -1

func handle_pawn_movement(grid_coords, click_position):
	var map_data = DatabaseManager.map_data
	# Only process if we have a pawn selected
	if selected_pawn_id != -1:
		var pawn = pawn_manager.get_pawn(selected_pawn_id)
		if pawn:
			# Check if target is valid
			if map_data.is_within_bounds_map(click_position):
				var target_tile = map_data.get_tile(grid_coords)
				if target_tile.walkable:
					# Command pawn to move to this location
					var success = pawn.move_to(grid_coords)
					if success:
						debug_path = pawn.movement_path
						if draw_pathfinder:
							# Update the path in map_renderer
							map.map_renderer.set_debug_path(debug_path)
							# Force redraw
							map.queue_redraw()


# for debugging, might be removed later
func handle_shift_click_territory_info(grid_coords: Vector2i) -> void:
	var map_data = DatabaseManager.map_data
	# Get the tile at the clicked position
	var tile = map_data.get_tile(grid_coords)
	
	# Check if the tile has territory owners
	if "territory_owner" in tile:
		var owners = tile["territory_owner"]
		print("=== TERRITORY INFO AT " + str(grid_coords) + " ===")
		
		# Handle different territory owner storage formats
		if typeof(owners) == TYPE_STRING:
			if "," in owners:
				# Multiple territories stored as comma-separated string
				var territory_list = owners.split(",")
				print("Multiple territories (" + str(territory_list.size()) + "):")
				for territory in territory_list:
					print_territory_details(territory.strip_edges() if typeof(territory) == TYPE_STRING else str(territory))

			else:
				# Single territory stored as string
				print("Single territory:")
				print_territory_details(owners)
		elif typeof(owners) == TYPE_ARRAY:
			# Multiple territories stored as array
			print("Multiple territories (" + str(owners.size()) + "):")
			for territory in owners:
				print_territory_details(territory)
		print("===============================")
	else:
		print("No territories at " + str(grid_coords))

func print_territory_details(territory_type: String) -> void:
	if territory_type == "":
		print("- Unknown Territory")
		print("  Rarity: Unknown")
		print("  Coexistence Layer: Unknown")
		print("  Preferred Terrain: []")
	else:
		var territory_data = territory_database.territory_definitions.get(territory_type, {})
		print("- " + territory_type.capitalize())
		print("  Rarity: " + str(territory_data.get("rarity", "Unknown")))
		print("  Coexistence Layer: " + str(territory_data.get("coexistence_layer", "Unknown")))
		print("  Preferred Terrain: " + str(territory_data.get("preferred_terrain", [])))

func handle_shift_right_click_terrain_info(grid_coords: Vector2i) -> void:
	var map_data = DatabaseManager.map_data
	# Get the tile at the clicked position
	var tile = map_data.get_tile(grid_coords)
	
	print("=== TERRAIN INFO AT " + str(grid_coords) + " ===")
	
	# Print terrain type
	if "terrain_type" in tile:
		var terrain_type = tile["terrain_type"]
		print("Terrain: " + terrain_type.capitalize())
		
		# Get terrain details from database
		var terrain_data = terrain_database.terrain_definitions[terrain_type]
		print("- Color: " + str(terrain_data.get("base_color", "Default")))
		print("- Walkable: " + str(terrain_data.get("walkable", true)))
		print("- Movement Cost: " + str(terrain_data.get("movement_cost", 1.0)))
	else:
		print("No terrain type defined")
	
	# Print subterrain type
	if "terrain_subtype" in tile:
		var terrain_subtype = tile["terrain_subtype"]
		print("\nSubterrain: " + terrain_subtype.capitalize())
		
		# Get subterrain details from database
		var subterrain_data = terrain_database.subterrain_definitions[terrain_subtype]
		print("- Color Modifier: " + str(subterrain_data.get("color_modifier", "none")))
		print("- Color Amount: " + str(subterrain_data.get("color_amount", 0)))
		print("- Walkable: " + str(subterrain_data.get("walkable", true)))
		print("- Movement Cost: " + str(subterrain_data.get("movement_cost", 1.0)))
		if "is_water" in subterrain_data:
			print("- Water: " + str(subterrain_data["is_water"]))
	else:
		print("\nNo subterrain type defined")
	
	# Print resources if present
	if "resources" in tile and tile["resources"].size() > 0:
		print("\nResources:")
		for resource_type in tile["resources"]:
			print("- " + resource_type + ": " + str(tile["resources"][resource_type]))
	
	# Print density value if available
	if "density" in tile:
		print("\nDensity Value: " + str(tile["density"]))
	
	print("===============================")


# Display pawn attributes
func display_pawn_attributes():
	var pawn = pawn_manager.get_pawn(selected_pawn_id)
	if pawn:
		print("\n=== ATTRIBUTES FOR " + pawn.pawn_name + " ===")
		print("Strength: " + str(pawn.strength) + " (Bonus: " + str(pawn.calculate_attribute_bonus(pawn.strength)) + ")")
		print("Dexterity: " + str(pawn.dexterity) + " (Bonus: " + str(pawn.calculate_attribute_bonus(pawn.dexterity)) + ")")
		print("Intelligence: " + str(pawn.intelligence) + " (Bonus: " + str(pawn.calculate_attribute_bonus(pawn.intelligence)) + ")")
		print("===============================")
	else:
		print("No pawn selected or attributes not initialized")

# Display pawn stats
func display_pawn_stats():
	var pawn = pawn_manager.get_pawn(selected_pawn_id)
	if pawn:
		print("\n=== STATS FOR " + pawn.pawn_name + " ===")
		print("Movement Speed: " + str(pawn.get_movement_speed()))
		print("Carrying Capacity: " + str(pawn.get_carrying_capacity()))
		print("Vision Range: " + str(pawn.get_vision_range()))
		print("Melee Damage: " + str(pawn.get_melee_damage()))
		print("Work Speed: " + str(pawn.get_work_speed()))
		print("Learning Rate: " + str(pawn.get_learning_rate()))
		
		# Show trait modifications
		print("\nTrait Modifications:")
		for stat_name in ["movement_speed", "vision_range", "melee_damage", "work_speed"]:
			var base_value = 0
			
			# Get base value for the stat
			match stat_name:
				"movement_speed":
					base_value = pawn.BASE_MOVEMENT_SPEED * (1.0 + pawn.calculate_attribute_bonus(pawn.dexterity) * 0.1)
				"vision_range":
					base_value = 5 + (pawn.dexterity * 0.2)
				"melee_damage":
					base_value = 10 + (pawn.strength * 2)
				"work_speed":
					base_value = 1.0 + (pawn.dexterity * 0.05)
			
			var modified_value = pawn.get_modified_stat(stat_name, base_value)
			
			if modified_value != base_value:
				var percentage = ((modified_value / base_value) - 1.0) * 100
				var sign = "+" if percentage >= 0 else ""
				print("- " + stat_name.capitalize() + ": " + sign + str(percentage) + "%")
		
		print("===============================")
	else:
		print("No pawn selected or stats not initialized")


# function to display mood information
func display_pawn_mood_info():
	var pawn = pawn_manager.get_pawn(selected_pawn_id)
	if pawn and pawn.mood_manager:
		print("\n=== MOOD INFO FOR " + pawn.pawn_name + " ===")
		print("Current Mood: " + str(pawn.mood_manager.current_mood) + "/100 (" + pawn.mood_manager.get_mood_state() + ")")
		
		# Display active modifiers
		if pawn.mood_manager.active_modifiers.size() > 0:
			print("\nActive Mood Modifiers:")
			for id in pawn.mood_manager.active_modifiers:
				var modifier = pawn.mood_manager.active_modifiers[id]
				var sign = "+" if modifier.value > 0 else ""
				print("- " + modifier.description + ": " + sign + str(modifier.value))
		else:
			print("\nNo active mood modifiers")
		
		# Display temporary modifiers with remaining duration
		if pawn.mood_manager.temporary_modifiers.size() > 0:
			print("\nTemporary Mood Modifiers:")
			for id in pawn.mood_manager.temporary_modifiers:
				var modifier = pawn.mood_manager.temporary_modifiers[id]
				var sign = "+" if modifier.value > 0 else ""
				print("- " + modifier.description + ": " + sign + str(modifier.value) +
					  " (Remaining: " + str(int(modifier.duration)) + "s)")
		else:
			print("\nNo temporary mood modifiers")
		
		# Display trait effects on mood if applicable
		print("\nTrait Effects on Mood:")
		var has_mood_traits = false
		for trait_name in pawn.traits:
			var trait_data = DatabaseManager.trait_database.get_trait(trait_name)
			if trait_data:
				var has_mood_effect = false
				var effect_text = ""
				
				# Check for mood-related effects
				if trait_data.effects.has("positive_mood_multiplier"):
					effect_text += "Positive mood x" + str(trait_data.effects.positive_mood_multiplier) + " "
					has_mood_effect = true
					
				if trait_data.effects.has("negative_mood_multiplier"):
					effect_text += "Negative mood x" + str(trait_data.effects.negative_mood_multiplier) + " "
					has_mood_effect = true
				
				if trait_data.effects.has("positive_mood_impact"):
					effect_text += "Positive impact x" + str(trait_data.effects.positive_mood_impact) + " "
					has_mood_effect = true
					
				if trait_data.effects.has("negative_mood_impact"):
					effect_text += "Negative impact x" + str(trait_data.effects.negative_mood_impact)
					has_mood_effect = true
				
				if has_mood_effect:
					print("- " + trait_name.capitalize() + ": " + effect_text)
					has_mood_traits = true
		
		if not has_mood_traits:
			print("- No traits affecting mood")
			
		print("===============================")
	else:
		print("No pawn selected or mood system not initialized")
