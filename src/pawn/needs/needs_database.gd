class_name NeedsDatabase
extends Resource

# Singleton pattern
static var instance = null

# Hunger need configuration
var hunger_config = {
    "initial_value": 100.0,
    "decay_rate": 0.08,
    "thresholds": {
        "critical": 10.0, # Starving
        "low": 25.0, # Hungry
        "satisfied": 75.0, # Well-fed
        "full": 95.0 # Stuffed
    },
    "nutrition_per_second": 10.0, # Rate of hunger satisfaction while eating
    "base_nutrition_value": 20.0 # Base nutrition from standard food
}

# Rest need configuration
var rest_config = {
    "initial_value": 10.0,
    "decay_rate": 0.05,
    "thresholds": {
        "critical": 15.0, # Exhausted
        "low": 30.0, # Tired
        "satisfied": 70.0, # Rested
        "full": 90.0 # Energetic
    },
    "rest_per_second": 8.0, # Rate of rest recovery while sleeping
    "base_rest_value": 30.0 # Base rest from standard sleeping spot
}

# Debug settings
var debug_mode = false
var debug_decay_multiplier = 1.0 # Set higher for faster testing

func _init():
    if instance == null:
        instance = self
    else:
        push_error("NeedsDatabase already exists!")

static func get_instance():
    if instance == null:
        instance = NeedsDatabase.new()
    return instance

# Helper function to get actual decay rate (accounting for debug settings)
func get_decay_rate(need_type: String) -> float:
    var base_rate = 0.05 # Default fallback
    
    if need_type == "Hunger":
        base_rate = hunger_config.decay_rate
    elif need_type == "Rest":
        base_rate = rest_config.decay_rate
    
    # Apply debug multiplier if in debug mode
    if debug_mode:
        return base_rate * debug_decay_multiplier
    else:
        return base_rate
