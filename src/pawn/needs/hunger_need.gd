class_name HungerNeed
extends Need

func _init():
    # Get the database instance
    var needs_database = DatabaseManager.needs_database
    
    # Initialize with values from database
    super._init(
        "Hunger",
        needs_database.hunger_config.initial_value,
        needs_database.get_decay_rate("Hunger")
    )
    
    # Set thresholds from database
    thresholds = needs_database.hunger_config.thresholds.duplicate()
    
# Function to consume food and reduce hunger
func eat_food(nutrition_value: float):
    increase(nutrition_value)
    return current_value
