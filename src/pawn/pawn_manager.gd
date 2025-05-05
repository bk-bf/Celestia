class_name PawnManager
extends Node

var pawns = {} # Dictionary of all pawns, keyed by ID
var next_pawn_id = 0
var map_data = null
@onready var pawn_info_ui = get_node("/root/Game/Main/PawnInfoUI")

func _init():
	pass

func initialize(map_reference):
	map_data = map_reference
	
# Create a new pawn at the specified position
func create_pawn(position: Vector2i) -> Pawn:
	var pawn = Pawn.new(next_pawn_id, position, map_data)
	pawn.generate_random_attributes()
	pawns[next_pawn_id] = pawn
	add_child(pawn)
	next_pawn_id += 1
	return pawn

# Get a pawn by ID
func get_pawn(pawn_id: int) -> Pawn:
	if pawns.has(pawn_id):
		return pawns[pawn_id]
	return null

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

# Create a pawn with a specific role tendency
func create_role_pawn(position: Vector2i, role: String) -> Pawn:
	var pawn = create_pawn(position)
	
	# Adjust attributes based on role
	match role.to_lower():
		"warrior":
			pawn.modify_attribute("strength", 3)
			pawn.modify_attribute("dexterity", 1)
			pawn.modify_attribute("intelligence", -1)
			pawn.pawn_name = "Warrior " + str(pawn.pawn_id)
		"scout":
			pawn.modify_attribute("dexterity", 3)
			pawn.modify_attribute("intelligence", 1)
			pawn.modify_attribute("strength", -1)
			pawn.pawn_name = "Scout " + str(pawn.pawn_id)
		"mage":
			pawn.modify_attribute("intelligence", 3)
			pawn.modify_attribute("dexterity", 1)
			pawn.modify_attribute("strength", -1)
			pawn.pawn_name = "Mage " + str(pawn.pawn_id)
		"balanced":
			pawn.modify_attribute("strength", 1)
			pawn.modify_attribute("dexterity", 1)
			pawn.modify_attribute("intelligence", 1)
			pawn.pawn_name = "Settler " + str(pawn.pawn_id)
	
	return pawn
