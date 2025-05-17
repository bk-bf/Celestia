class_name DesignationManager
extends Node

# Singleton pattern
static var instance = null

# Dictionary to store designations by type and position
# Format: { "designation_type": { Vector2i(x, y): designation_data } }
var designations = {
    "harvest": {},
    "construct": {},
    "mine": {},
    "clear": {},
    "haul": {}
}


# Reference to required managers
var map_data = null

# Signals
signal designation_added(type, position, data)
signal designation_removed(type, position)
signal designation_completed(type, position)
signal designations_changed # General signal for map renderer to update

func _init():
    if instance == null:
        instance = self
    else:
        push_error("DesignationManager already exists!")

func _ready():
    # Get references to required managers
    map_data = DatabaseManager.map_data

static func get_instance():
    if instance == null:
        instance = DesignationManager.new()
    return instance

# Add a designation at the specified position
func add_designation(type: String, position: Vector2i, data: Dictionary = {}):
    # Validate designation type
    if not designations.has(type):
        push_error("Invalid designation type: " + type)
        return false
    
    # Check if position is valid
    if not map_data.is_within_bounds_map(position):
        push_error("Position out of bounds: " + str(position))
        return false
    
    # Check if designation already exists
    if designations[type].has(position):
        # Update existing designation
        designations[type][position].merge(data)
        emit_signal("designation_added", type, position, designations[type][position])
        emit_signal("designations_changed")
        return true
    
    # Add new designation
    designations[type][position] = data
    
    # Emit signals
    emit_signal("designation_added", type, position, data)
    emit_signal("designations_changed")
    
    print("Added " + type + " designation at " + str(position))
    return true

# Remove a designation at the specified position
func remove_designation(type: String, position: Vector2i):
    # Validate designation type
    if not designations.has(type):
        push_error("Invalid designation type: " + type)
        return false
    
    # Check if designation exists
    if not designations[type].has(position):
        return false
    
    # Remove designation
    designations[type].erase(position)
    
    # Emit signals
    emit_signal("designation_removed", type, position)
    emit_signal("designations_changed")
    
    print("Removed " + type + " designation at " + str(position))
    return true

# Complete a designation (called when job is finished)
func complete_designation(type: String, position: Vector2i):
    # Validate designation type
    if not designations.has(type):
        push_error("Invalid designation type: " + type)
        return false
    
    # Check if designation exists
    if not designations[type].has(position):
        return false
    
    # Remove designation
    designations[type].erase(position)
    
    # Emit signals
    emit_signal("designation_completed", type, position)
    emit_signal("designations_changed")
    
    print("Completed " + type + " designation at " + str(position))
    return true

# Check if a position has a designation of the specified type
func has_designation(type: String, position: Vector2i) -> bool:
    if not designations.has(type):
        return false
    return designations[type].has(position)

# Get all designations of a specific type
func get_designations_by_type(type: String) -> Dictionary:
    if not designations.has(type):
        return {}
    return designations[type]

# Get all designations at a specific position
func get_designations_at_position(position: Vector2i) -> Dictionary:
    var result = {}
    for type in designations.keys():
        if designations[type].has(position):
            result[type] = designations[type][position]
    return result

# Find the nearest designation of a specific type to a position
func find_nearest_designation(type: String, from_position: Vector2i) -> Vector2i:
    if not designations.has(type) or designations[type].empty():
        return Vector2i(-1, -1)
    
    var nearest_pos = Vector2i(-1, -1)
    var nearest_distance = INF
    
    for pos in designations[type].keys():
        var distance = from_position.distance_to(pos)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_pos = pos
    
    return nearest_pos

# Clear all designations
func clear_all_designations():
    for type in designations.keys():
        designations[type].clear()
    
    emit_signal("designations_changed")
    print("Cleared all designations")
