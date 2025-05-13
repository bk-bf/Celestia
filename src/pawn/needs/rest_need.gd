class_name RestNeed
extends Need

func _init():
    super._init("Rest", 100.0, 0.05) # Start fully rested, decay slower
    
    # Customize thresholds if needed
    thresholds = {
        "critical": 15.0, # Exhausted
        "low": 30.0, # Tired
        "satisfied": 70.0, # Rested
        "full": 90.0 # Energetic
    }
    
# Function to sleep and recover rest
func sleep(recovery_rate: float):
    increase(recovery_rate)
    return current_value
