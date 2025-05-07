class_name PawnManager
extends Node

var pawns = {} # Dictionary of all pawns, keyed by ID
var next_pawn_id = 0
var map_data = null

func _init():
	pass

func initialize(map_reference):
	map_data = map_reference
	
# Create a new pawn at the specified position
func create_pawn(position: Vector2i):
	var new_pawn = Pawn.new(next_pawn_id, position, map_data)
	pawns[next_pawn_id] = new_pawn
	add_child(new_pawn)
	next_pawn_id += 1
	return new_pawn

# Get a pawn by ID
func get_pawn(pawn_id: int) -> Pawn:
	if pawns.has(pawn_id):
		return pawns[pawn_id]
	return null

# Helper function to find the nearest walkable tile
func find_nearest_walkable_tile(position: Vector2i) -> Vector2i:
	# Start with the given position
	var search_radius = 1
	var max_search_radius = 10 # Limit search to prevent infinite loops
	
	while search_radius <= max_search_radius:
		# Check tiles in expanding squares around the position
		for y in range(position.y - search_radius, position.y + search_radius + 1):
			for x in range(position.x - search_radius, position.x + search_radius + 1):
				# Skip if out of bounds
				if x < 0 or y < 0 or x >= map_data.get_width() or y >= map_data.get_height():
					continue
					
				# Skip if not on the perimeter of the current search square
				if search_radius > 1 and x > position.x - search_radius and x < position.x + search_radius and y > position.y - search_radius and y < position.y + search_radius:
					continue
				
				# Check if this tile is walkable
				var tile = map_data.get_tile(Vector2i(x, y))
				if tile.walkable:
					print("Found walkable tile at: ", Vector2i(x, y))
					return Vector2i(x, y)
		
		# Expand search radius
		search_radius += 1
	
	# If no walkable tile found, return original position and log warning
	print("WARNING: No walkable tile found near ", position)
	return position

func get_selected_pawn():
	for pawn_id in pawns:
		if pawns[pawn_id].is_selected:
			return pawns[pawn_id]
	print("No pawn is currently selected")
	return null

# Get all pawns
func get_all_pawns() -> Array:
	return pawns.values()

# Remove a pawn
func remove_pawn(pawn_id: int) -> bool:
	if pawns.has(pawn_id):
		var pawn = pawns[pawn_id]
		pawns.erase(pawn_id)
		pawn.queue_free()
		return true
	return false

func _on_pawn_selected(pawn):
	# Other selection code...
	# Update the UI
	var pawn_ui = get_node("../PawnInfoUI")
	if pawn_ui:
		pawn_ui.set_selected_pawn(pawn)
