extends Node

# References to major subsystems
var pawn_manager = null

func _ready():
	# Get reference to your existing map
	var map = $Map
	
	# Access the map_data through your map's getter
	var map_data = map.map_data
	
	# Initialize the pawn manager with map_data reference
	pawn_manager = PawnManager.new(map_data)
	add_child(pawn_manager)
	
	# Create some initial test pawns in the center area
	for i in range(3): # Create 3 pawns
		var center_position = map_data.get_random_center_position()
		var test_pawn = pawn_manager.create_pawn(center_position)
		print("Created test pawn " + str(i) + " at position: ", center_position)


# Handle user input for selecting and moving pawns
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Get reference to map and map_data
		var map = $Map
		var map_data = map.map_data
		
		# Convert mouse position to grid coordinates
		var mouse_pos = get_viewport().get_mouse_position()
		var grid_coords = map_data.map_to_grid(mouse_pos)
		
		# Here you would implement pawn selection and movement
		print("Clicked at grid coordinates: ", grid_coords)
		
		# Check if we clicked on a valid tile
		if map_data.is_within_bounds_map(mouse_pos):
			var tile = map_data.get_tile(grid_coords)
			print("Tile terrain: ", tile.terrain_type)
