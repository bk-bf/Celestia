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

func complete_without_rest():
    # Complete the job without adding rest (since it's added incrementally)
    if assigned_pawn:
        print("Pawn " + str(assigned_pawn.pawn_id) + " finished sleeping")
    return true
