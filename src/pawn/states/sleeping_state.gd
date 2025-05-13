class_name SleepingState
extends PawnState

var state_name: String

var sleeping_progress: float = 0.0
var sleeping_duration: float = 5.0 # Base time to sleep

func _init():
    state_name = "Sleeping"


func enter():
    print("Pawn " + str(pawn.pawn_id) + " is sleeping")
    sleeping_progress = 0.0
    
    # Pause the rest need decay while sleeping
    if pawn.needs.has("rest"):
        pawn.needs["rest"].pause()
    
    # Adjust sleeping duration based on job if available
    if pawn.current_job and pawn.current_job.type == "sleeping":
        sleeping_duration = pawn.current_job.time_required


func update(delta):
    sleeping_progress += delta
    
    # Get the rest rate from the database
    var needs_database = NeedsDatabase.get_instance()
    var rest_per_second = needs_database.rest_config.rest_per_second
    
    # Gradually recover rest as sleeping progresses
    if pawn.needs.has("rest"):
        pawn.needs["rest"].increase(rest_per_second * delta)
    
    # Check if we should wake up
    if sleeping_progress >= sleeping_duration or (pawn.needs.has("rest") and pawn.needs["rest"].current_value >= 95):
        print("Pawn " + str(pawn.pawn_id) + " woke up")
        
        # Complete the job but don't add rest (it's already been added incrementally)
        if pawn.current_job:
            # Just mark the job as complete without additional rest
            pawn.current_job.complete_without_rest()
            pawn.current_job = null
            
        state_machine.change_state("Idle")

func exit():
    # Resume the rest need decay when finished sleeping
    if pawn.needs.has("rest"):
        pawn.needs["rest"].resume()
        
    sleeping_progress = 0.0
