class_name HarvestingJob
extends Job

func _init(pos, resource_type, amount, time = 2.0):
    super._init(pos, resource_type, amount, time)
    type = "harvesting"

func complete():
    # Calculate the amount harvested
    var harvested_amount = calculate_harvest_amount()
    
    # Log the harvesting event
    if DebugLogger.instance:
        DebugLogger.instance.log_resource_harvested(
            assigned_pawn.name,
            job_type,
            harvested_amount,
            target_position
        )
    
    # Emit signal before returning
    if assigned_pawn:
        emit_signal("job_completed", assigned_pawn.pawn_id, job_type, {
            "amount": harvested_amount,
            "position": target_position
        })
    
    # Return the harvested resources
    return {
        "type": job_type,
        "amount": harvested_amount
    }
	
func calculate_harvest_amount():
    # Get the resource definition from the database
    var resource_db = ResourceDatabase.new()
    var resource_def = resource_db.get_resource(job_type) # Changed from resource_type
    
    if resource_def:
        # Instead of using yield_amount for randomization,
        # just return the full amount available on the tile
        return amount # Changed from amount_available
    else:
        # Fallback if resource definition not found
        return min(1, amount) # Changed from amount_available
