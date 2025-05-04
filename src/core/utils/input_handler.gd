extends Node2D

# References to other nodes
@onready var map = get_node("../Map")
@onready var main = get_parent()
@export var draw_pathfinder: bool = false

# Pawn selection tracking
var selected_pawn_id = -1
var debug_path = []

func _ready():
	# Wait until map generation is complete
	await get_tree().create_timer(0.5).timeout
	print("InputHandler initialized")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var click_position = get_global_mouse_position()
		var grid_coords = map.map_data.map_to_grid(click_position)
		
		# Handle left-click for pawn selection
		if event.button_index == MOUSE_BUTTON_LEFT:
			handle_pawn_selection(grid_coords)
		
		# Handle right-click for movement
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			handle_pawn_movement(grid_coords, click_position)
	

func handle_pawn_selection(grid_coords):
	var pawn_manager = main.pawn_manager
	
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
	var pawn_manager = main.pawn_manager
	var map_data = map.map_data
	
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
