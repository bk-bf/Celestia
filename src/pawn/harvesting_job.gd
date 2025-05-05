# HarvestingJob.gd
class_name HarvestingJob
extends Resource

var target_position = Vector2i() # Grid position of the resource
var resource_type = "" # Type of resource to harvest
var amount_available = 0 # Amount available to harvest
var time_to_harvest = 2.0 # Time in seconds to harvest
var progress = 0.0 # Current progress (0.0 to 1.0)
var assigned_pawn = null # Reference to the assigned pawn

func _init(pos, type, amount, time = 2.0):
    target_position = pos
    resource_type = type
    amount_available = amount
    time_to_harvest = time

func is_complete():
    return progress >= 1.0

func complete_harvesting():
    # Calculate the amount harvested
    var harvested_amount = calculate_harvest_amount()
    
    # Log the harvesting event
    if DebugLogger.instance:
        DebugLogger.instance.log_resource_harvested(
            assigned_pawn.name,
            resource_type,
            harvested_amount,
            target_position
        )
    
    # Return the harvested resources
    return {
        "type": resource_type,
        "amount": harvested_amount
    }

func calculate_harvest_amount():
    # Get the resource definition from the database
    var resource_db = ResourceDatabase.new()
    var resource_def = resource_db.get_resource(resource_type)
    
    if resource_def:
        # Instead of using yield_amount for randomization,
        # just return the full amount available on the tile
        return amount_available
    else:
        # Fallback if resource definition not found
        return min(1, amount_available)
