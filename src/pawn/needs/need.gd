class_name Need
extends Node

# Signal declaration
signal value_changed(need_name, old_value, new_value, state)

# Core properties
var current_value: float = 100.0 # Start at maximum (fully satisfied)
var max_value: float = 100.0
var min_value: float = 0.0
var need_name: String = "GenericNeed"

# Decay rate (amount lost per second)
var decay_rate: float = 0.05 # Default value, will be customized per need

# Thresholds for different states
var thresholds = {
    "critical": 15.0, # Below this is critical (starving/exhausted)
    "low": 30.0, # Below this is low (hungry/tired)
    "satisfied": 70.0, # Above this is satisfied (well-fed/rested)
    "full": 90.0 # Above this is full (stuffed/energetic)
}

# Owner reference
var pawn = null

func _init(need_name: String, initial_value: float = 100.0, decay: float = 0.05):
    name = need_name
    current_value = initial_value
    decay_rate = decay

func _process(delta):
    # Apply decay over timed
    decrease(decay_rate * delta)

# Decrease the need value (hunger increases, energy decreases)
func decrease(amount: float):
    current_value = max(min_value, current_value - amount)
    
# Increase the need value (eating food, sleeping)
func increase(amount: float):
    current_value = min(max_value, current_value + amount)
    
# Get the current state based on thresholds
func get_state() -> String:
    if current_value <= thresholds.critical:
        return "critical"
    elif current_value <= thresholds.low:
        return "low"
    elif current_value >= thresholds.full:
        return "full"
    elif current_value >= thresholds.satisfied:
        return "satisfied"
    else:
        return "normal"
        
# Check if this need is at a critical level
func is_critical() -> bool:
    return current_value <= thresholds.critical
    
# Check if this need requires attention
func needs_attention() -> bool:
    return current_value <= thresholds.low
