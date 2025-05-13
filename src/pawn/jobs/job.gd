# Job.gd
class_name Job
extends Resource

var target_position = Vector2i() # Grid position for the job
var job_type = "" # Type of resource/object/location
var amount = 0 # Amount to process (if applicable)
var time_required = 2.0 # Time in seconds to complete
var progress = 0.0 # Current progress (0.0 to 1.0)
var assigned_pawn = null # Reference to the assigned pawn
var type = "generic" # Job category (eating, sleeping, harvesting, etc.)

func _init(position, job_type_value, amount_value, time = 2.0):
    target_position = position
    job_type = job_type_value
    amount = amount_value
    time_required = time

func is_complete():
    return progress >= 1.0

# Base method to be overridden by specific job types
func complete():
    return true
