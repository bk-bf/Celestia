class_name SleepingState
extends PawnState

var sleeping_progress: float = 0.0
var sleeping_duration: float = 5.0 # Base time to sleep, now used as minimum time

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
    
    # Check if we should wake up - now prioritizing rest level over time
    var should_wake_up = false
    
    # Always wake up if rest is full (95+)
    if pawn.needs.has("rest") and pawn.needs["rest"].current_value >= 95:
        should_wake_up = true
    # Only wake up after minimum time if not fully rested
    elif sleeping_progress >= sleeping_duration:
        # If job has sleep_until_rested flag, only wake if rest is above 90
        if pawn.current_job and pawn.current_job.sleep_until_rested:
            if pawn.needs["rest"].current_value >= 95:
                should_wake_up = true
        else:
            # For jobs without the flag, wake up after time expires
            should_wake_up = true
    
    if should_wake_up:
        print("Pawn " + str(pawn.pawn_id) + " woke up")
        
        # Complete the job
        if pawn.current_job:
            pawn.current_job.complete_without_rest()
            pawn.current_job = null
            
        state_machine.change_state("Idle")

func exit():
    # Resume the rest need decay when finished sleeping
    if pawn.needs.has("rest"):
        pawn.needs["rest"].resume()
        
    sleeping_progress = 0.0
