class_name HungerNeed
extends Need

func _init():
    super._init("Hunger", 80.0, 0.08) # Start at 80%, decay faster than rest
    
    # Customize thresholds if needed
    thresholds = {
        "critical": 10.0, # Starving
        "low": 25.0, # Hungry
        "satisfied": 75.0, # Well-fed
        "full": 95.0 # Stuffed
    }
    
# Function to consume food and reduce hunger
func eat_food(nutrition_value: float):
    increase(nutrition_value)
    return current_value
