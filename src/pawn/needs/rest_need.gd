class_name RestNeed
extends Need

func _init():
    # Get the database instance
    var needs_database = DatabaseManager.needs_database
    
    # Initialize with values from database
    super._init(
        "Rest",
        needs_database.rest_config.initial_value,
        needs_database.get_decay_rate("Rest")
    )
    
    # Set thresholds from database
    thresholds = needs_database.rest_config.thresholds.duplicate()
    
# Function to sleep and recover rest
func sleep(recovery_rate: float):
    increase(recovery_rate)
    return current_value
