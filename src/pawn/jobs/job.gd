# Job.gd
class_name Job
extends Resource

var pawn_id: int
var target_position = Vector2i() # Grid position for the job
var job_type = "" # Type of resource/object/location
var job_details: Dictionary = {}
var amount = 0 # Amount to process (if applicable)
var time_required = 2.0 # Time in seconds to complete
var progress = 0.0 # Current progress (0.0 to 1.0)
var assigned_pawn = null # Reference to the assigned pawn
var type = "generic" # Job category (eating, sleeping, harvesting, etc.)


signal job_updated(pawn_id, job_type, job_details)
signal job_completed(pawn_id, job_type, job_details)


func _init(position, job_type_value, amount_value, time = 2.0):
    target_position = position
    job_type = job_type_value
    amount = amount_value
    time_required = time

func is_complete():
    return progress >= 1.0

func job_to_string():
    return "Job(type=%s, object=%s, target=%s, amount=%d, time=%.2f)" % [type, job_type, str(target_position), amount, time_required]

# Base method to be overridden by specific job types
func complete():
    return true
	
# When job status changes
func update_job_status():
    emit_signal("job_updated", pawn_id, job_type, job_details)
