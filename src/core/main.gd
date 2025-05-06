extends Node

# References to major subsystems
var pawn_manager = null
var selected_pawn_id = -1 # Track the currently selected pawn

func _ready():
	# Get reference to your existing map
	var map = $Map
	# Access the map_data through your map's getter
	var map_data = map.map_data

	# Get reference to existing PawnManager node
	pawn_manager = $PawnManager
	
	# Initialize it with map_data
	pawn_manager.initialize(map_data)
	# Create some initial test pawns in the center area
	for i in range(10): # Spawn pawns
		var center_position = map_data.get_random_center_position()
		var test_pawn = pawn_manager.create_pawn(center_position)
		print("Created test pawn " + str(i) + " at position: ", center_position)
