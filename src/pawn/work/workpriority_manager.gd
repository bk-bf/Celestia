class_name WorkPriorityManager
extends Node

# Singleton pattern
static var instance = null

# Dictionary to store work priorities for each pawn
# Format: { pawn_id: { work_type_id: priority_level } }
var pawn_priorities = {}

# Work priority levels
const PRIORITY_DISABLED = 0
const PRIORITY_LOW = 1
const PRIORITY_NORMAL = 2
const PRIORITY_HIGH = 3
const PRIORITY_URGENT = 4

# Reference to required managers
var work_type_database = null
var pawn_manager = null

# Signals
signal priorities_changed(pawn_id, work_type_id)

func _init():
    if instance == null:
        instance = self
    else:
        push_error("WorkPriorityManager already exists!")

func _ready():
    # Get references to required databases
    if DatabaseManager:
        work_type_database = DatabaseManager.work_type_database
        
    # Get reference to pawn manager
    if DatabaseManager.pawn_manager:
        pawn_manager = DatabaseManager.pawn_manager
        
        # Initialize priorities for existing pawns
        for pawn in pawn_manager.get_all_pawns():
            initialize_pawn_priorities(pawn.pawn_id)

static func get_instance():
    if instance == null:
        instance = WorkPriorityManager.new()
    return instance

# Initialize priorities for a new pawn
func initialize_pawn_priorities(pawn_id):
    if pawn_priorities.has(pawn_id):
        return
        
    pawn_priorities[pawn_id] = {}
    
    # Default all work types to normal priority
    for work_type_id in work_type_database.work_types.keys():
        pawn_priorities[pawn_id][work_type_id] = PRIORITY_NORMAL
    
    # Adjust based on pawn traits/skills
    var pawn = pawn_manager.get_pawn(pawn_id)
    if pawn:
        _adjust_priorities_based_on_traits(pawn_id, pawn.traits)

# Set priority for a specific pawn and work type
func set_priority(pawn_id, work_type_id, priority_level):
    if not pawn_priorities.has(pawn_id):
        initialize_pawn_priorities(pawn_id)
        
    # Clamp priority level to valid range
    priority_level = clamp(priority_level, PRIORITY_DISABLED, PRIORITY_URGENT)
    
    # Set the priority
    pawn_priorities[pawn_id][work_type_id] = priority_level
    
    # Emit signal
    emit_signal("priorities_changed", pawn_id, work_type_id)
    
    print("Set priority for pawn " + str(pawn_id) + " work " +
          work_type_id + " to " + str(priority_level))

# Get priority for a specific pawn and work type
func get_priority(pawn_id, work_type_id):
    if not pawn_priorities.has(pawn_id):
        initialize_pawn_priorities(pawn_id)
    
    if pawn_priorities[pawn_id].has(work_type_id):
        return pawn_priorities[pawn_id][work_type_id]
    
    return PRIORITY_NORMAL # Default

# Cycle priority for a specific pawn and work type
func cycle_priority(pawn_id, work_type_id):
    var current = get_priority(pawn_id, work_type_id)
    var next = (current + 1) % (PRIORITY_URGENT + 1)
    set_priority(pawn_id, work_type_id, next)
    return next

# Get all priorities for a pawn
func get_pawn_priorities(pawn_id):
    if not pawn_priorities.has(pawn_id):
        initialize_pawn_priorities(pawn_id)
    
    return pawn_priorities[pawn_id].duplicate()

# Find the highest priority work type for a pawn
func get_highest_priority_work_type(pawn_id):
    if not pawn_priorities.has(pawn_id):
        initialize_pawn_priorities(pawn_id)
    
    var highest_priority = PRIORITY_DISABLED
    var highest_work_type = ""
    
    for work_type_id in pawn_priorities[pawn_id].keys():
        var priority = pawn_priorities[pawn_id][work_type_id]
        if priority > highest_priority:
            highest_priority = priority
            highest_work_type = work_type_id
    
    return highest_work_type

# Get pawns that can do a specific work type, sorted by priority
func get_pawns_for_work_type(work_type_id):
    var result = []
    
    for pawn_id in pawn_priorities.keys():
        if pawn_priorities[pawn_id].has(work_type_id) and pawn_priorities[pawn_id][work_type_id] > PRIORITY_DISABLED:
            result.append({
                "pawn_id": pawn_id,
                "priority": pawn_priorities[pawn_id][work_type_id]
            })
    
    # Sort by priority (highest first)
    result.sort_custom(func(a, b): return a.priority > b.priority)
    
    return result

# Private methods
func _adjust_priorities_based_on_traits(pawn_id, traits):
    # Example trait effects (expand based on your trait system)
    for trait_name in traits:
        match trait_name:
            "nature_lover":
                set_priority(pawn_id, "harvesting", PRIORITY_HIGH)
            "strong":
                set_priority(pawn_id, "mining", PRIORITY_HIGH)
                set_priority(pawn_id, "hauling", PRIORITY_HIGH)
            "builder":
                set_priority(pawn_id, "construction", PRIORITY_HIGH)
            "chef":
                set_priority(pawn_id, "cooking", PRIORITY_HIGH)
