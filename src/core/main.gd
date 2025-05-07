extends Node

# References to major subsystems
var pawn_manager = DatabaseManager.pawn_manager
var terrain_database = DatabaseManager.terrain_database
var map_data: MapData
#var selected_paw
var center_position = null

# Get references to your TileMap nodes
@onready var terrain_tilemap = $Map/TerrainTileMap
@onready var subterrain_tilemap = $Map/SubTerrainTileMap

func _ready():
	# Get reference to your existing map
	var map = $Map
	# Access the map_data through your map's getter
	var map_data = map.map_data
	
	# initialize TileMapLayers 
	#map.initialize_tilemaps(terrain_tilemap, subterrain_tilemap)
	
	# Get reference to existing PawnManager node
	pawn_manager = $PawnManager
	
	# Initialize it with map_data 
	pawn_manager.initialize(map_data)
	
	# Create some initial test pawns in the center area
	for i in range(5): # Spawn x pawns
		center_position = map_data.get_random_center_position()
		var test_pawn = pawn_manager.create_pawn(center_position)
		print("Created test pawn " + str(i) + " at position: ", center_position)
	
	# Clear territories around the center position where pawns spawn
	clear_territories_around_center(center_position)

	# Set up signal connections for resource changes (now updates subterrain)
#	map_data.connect("tile_resource_changed", _on_tile_resource_changed)


func clear_territories_around_center(center_position: Vector2i, radius: int = 30) -> void:
	var map_data = DatabaseManager.map_data
	if center_position == null:
		print("Error: No center position provided")
		return
	
	print("Clearing territories in a " + str(radius * 2) + "x" + str(radius * 2) + " area around " + str(center_position))
	
	# Define the area boundaries (square bounding box)
	var min_x = max(0, center_position.x - radius)
	var max_x = min(map_data.get_width() - 1, center_position.x + radius)
	var min_y = max(0, center_position.y - radius)
	var max_y = min(map_data.get_height() - 1, center_position.y + radius)

	# Clear territories in the defined area (circular shape)
	var cleared_count = 0
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			# Calculate distance from center (using squared distance for efficiency)
			var dx = x - center_position.x
			var dy = y - center_position.y
			
			# Check if within circle radius (using squared distance)
			if dx * dx + dy * dy <= radius * radius:
				# This tile is within the circular area
				var tile = map_data.get_tile(Vector2i(x, y))
				if "territory_owner" in tile and tile["territory_owner"] != "":
					tile["territory_owner"] = ""
					cleared_count += 1

	print("Cleared territories from " + str(cleared_count) + " tiles")
	
	# Update the monster_territories list to remove any territories that were completely cleared
	var territories_to_remove = []
	for i in range(map_data.monster_territories.size()):
		var territory = map_data.monster_territories[i]
		var seed_point = territory["seed"]
		
		# Check if the seed point of this territory was in the cleared area
		if seed_point.x >= min_x and seed_point.x <= max_x and seed_point.y >= min_y and seed_point.y <= max_y:
			territories_to_remove.append(i)
	
	# Remove territories from the list (in reverse order to avoid index issues)
	for i in range(territories_to_remove.size() - 1, -1, -1):
		map_data.monster_territories.remove_at(territories_to_remove[i])
	
	print("Removed " + str(territories_to_remove.size()) + " territories from tracking list")
