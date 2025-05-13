class_name SleepingState
extends PawnState

var sleeping_progress: float = 0.0
var sleeping_duration: float = 5.0 # Base time to sleep

func _init():
    var state_name = "Sleeping"

func enter():
    print("Pawn " + str(pawn.pawn_id) + " is sleeping")
    sleeping_progress = 0.0
    
    # Adjust sleeping duration based on job if available
    if pawn.current_job and pawn.current_job.type == "sleeping":
        sleeping_duration = pawn.current_job.time_required

func update(delta):
    sleeping_progress += delta
    
    # Gradually recover rest as sleeping progresses
    if pawn.needs.has("rest"):
        var rest_per_second = 8.0 # Rest gained per second while sleeping
        pawn.needs["rest"].increase(rest_per_second * delta)
    
    # Check if we should wake up
    # Fixed the syntax error by putting the condition on a single line
    if sleeping_progress >= sleeping_duration or (pawn.needs.has("rest") and pawn.needs["rest"].current_value >= 95):
        print("Pawn " + str(pawn.pawn_id) + " woke up")
        
        # Complete the job
        if pawn.current_job:
            pawn.current_job.complete()
            pawn.current_job = null
            
        state_machine.change_state("Idle")

func exit():
    sleeping_progress = 0.0
