class_name InputHandler
extends Node2D

# References to other nodes
@onready var map = get_node("../Map")
@onready var main = get_parent()
var pawn_manager
@export var draw_pathfinder: bool = false

# Pawn selection tracking
var selected_pawn_id = -1
var debug_path = []

func _ready():
	# Wait until map generation is complete
	await get_tree().create_timer(0.5).timeout
	var map_data = MapDataManager.map_data # autoload/singleton for Resource
	print("InputHandler initialized")
	# Get reference to the PawnManager
	pawn_manager = get_node("/root/Game/Main/PawnManager")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var click_position = get_global_mouse_position()
		var grid_coords = MapDataManager.map_data.map_to_grid(click_position)

		# Handle left-click for pawn selection
		if event.button_index == MOUSE_BUTTON_LEFT:
			handle_pawn_selection(grid_coords)

		# Handle right-click for movement
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			handle_pawn_movement(grid_coords, click_position)

		# Handle middle-click for resource harvesting
		elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			if MapDataManager.map_data.is_within_bounds_map(grid_coords):
				print("middle mouse button clicked on map")
				# Check if there's a resource at this position
				var tile = MapDataManager.map_data.get_tile(grid_coords)
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


func handle_pawn_selection(grid_coords):
	# Check if we clicked on a pawn
	var clicked_on_pawn = false
	for pawn in pawn_manager.get_all_pawns():
		if pawn.current_tile_position == grid_coords:
			# Select this pawn
			selected_pawn_id = pawn.pawn_id
			clicked_on_pawn = true
			print("Selected pawn: " + pawn.pawn_name)

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
	# Only process if we have a pawn selected
	if selected_pawn_id != -1:
		var pawn = pawn_manager.get_pawn(selected_pawn_id)
		if pawn:
			# Check if target is valid
			if MapDataManager.map_data.is_within_bounds_map(click_position):
				var target_tile = MapDataManager.map_data.get_tile(grid_coords)
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
