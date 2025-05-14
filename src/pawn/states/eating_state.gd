class_name EatingState
extends PawnState


var eating_progress: float = 0.0
var eating_duration: float = 2.0 # Base time to eat
var message_printed = false

func enter():
    if !message_printed:
        print("Pawn " + str(pawn.pawn_id) + " is eating")
        message_printed = true
        
    eating_progress = 0.0
    
    # Pause the hunger need decay while eating
    if pawn.needs.has("hunger"):
        pawn.needs["hunger"].pause()
    
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
    
    # Check if we should finish eating
    if eating_progress >= eating_duration or (pawn.needs.has("hunger") and pawn.needs["hunger"].current_value >= 95):
        if !message_printed: # Only print if we haven't already
            print("Pawn " + str(pawn.pawn_id) + " finished eating")
        
        # Complete the job
        if pawn.current_job:
            pawn.current_job.complete_without_nutrition()
            pawn.current_job = null
            
        # Check if pawn is still hungry after this meal
        if pawn.needs.has("hunger") and pawn.needs["hunger"].current_value < needs_database.hunger_config.thresholds.satisfied:
            # Still hungry, look for more food
            state_machine.change_state("Hungry")
        else:
            # Satisfied, return to idle
            state_machine.change_state("Idle")
			
func exit():
    # Resume the hunger need decay when finished eating
    if pawn.needs.has("hunger"):
        pawn.needs["hunger"].resume()
        
    eating_progress = 0.0
    message_printed = false # Reset message flag when exiting
