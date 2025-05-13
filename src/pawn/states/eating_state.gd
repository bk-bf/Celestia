class_name EatingState
extends PawnState


var state_name: String
var eating_progress: float = 0.0
var eating_duration: float = 2.0 # Base time to eat
var message_printed = false

func _init():
    state_name = "Eating" # Fixed: This should be a property assignment, not a local variable

func enter():
    if !message_printed:
        print("Pawn " + str(pawn.pawn_id) + " is eating")
        message_printed = true
        
    eating_progress = 0.0
    
    # Safety check - make sure we have a job
    if not pawn.current_job:
        print("EatingState: No job assigned! Returning to Idle.")
        state_machine.change_state("Idle")
        return
    
    # Adjust eating duration based on job if available
    if pawn.current_job and pawn.current_job.type == "eating":
        eating_duration = pawn.current_job.time_required

func update(delta):
    # Safety check
    if not pawn.current_job:
        state_machine.change_state("Idle")
        return
        
    eating_progress += delta
    
    # Get the nutrition rate from the database
    var needs_database = NeedsDatabase.get_instance()
    var nutrition_per_second = needs_database.hunger_config.nutrition_per_second
    
    # Update hunger as we eat
    if eating_progress > 0.5: # Start satisfying hunger halfway through eating
        if pawn.needs.has("hunger"):
            pawn.needs["hunger"].increase(nutrition_per_second * delta)
    
    # Finished eating
    if eating_progress >= eating_duration:
        if !message_printed: # Only print if we haven't already
            print("Pawn " + str(pawn.pawn_id) + " finished eating")
        
        # Complete the job
        if pawn.current_job:
            pawn.current_job.complete()
            pawn.current_job = null
            
        state_machine.change_state("Idle")

func exit():
    eating_progress = 0.0
    message_printed = false # Reset message flag when exiting
