# SleepingJob.gd
class_name SleepingJob
extends Job

var rest_value: float = 30.0 # Base rest provided by this sleeping spot

func _init(position, bed_type, amount, time_required):
    super._init(position, bed_type, amount, time_required)
    type = "sleeping"
    
    # Different bed types could provide different rest values
    if bed_type == "bed":
        rest_value = 40.0
    elif bed_type == "simple_spot":
        rest_value = 20.0

func complete():
    # Give rest to the pawn
    if assigned_pawn:
        assigned_pawn.needs["rest"].increase(rest_value)
        print("Pawn " + str(assigned_pawn.pawn_id) + " recovered rest by " + str(rest_value))
    return true
