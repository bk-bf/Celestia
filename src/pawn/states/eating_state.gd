class_name EatingState
extends PawnState

var eating_progress: float = 0.0
var eating_duration: float = 2.0 # Base time to eat

func _init():
    var state_name = "Eating"

func enter():
    print("Pawn " + str(pawn.pawn_id) + " is eating")
    eating_progress = 0.0
    
    # Adjust eating duration based on job if available
    if pawn.current_job and pawn.current_job.type == "eating":
        eating_duration = pawn.current_job.time_required

func update(delta):
    eating_progress += delta
    
    # Gradually satisfy hunger as eating progresses
    if pawn.needs.has("hunger"):
        var nutrition_per_second = 10.0 # Nutrition gained per second while eating
        pawn.needs["hunger"].increase(nutrition_per_second * delta)
    
    # Finished eating
    if eating_progress >= eating_duration:
        print("Pawn " + str(pawn.pawn_id) + " finished eating")
        
        # Complete the job
        if pawn.current_job:
            pawn.current_job.complete()
            pawn.current_job = null
            
        state_machine.change_state("Idle")

func exit():
    eating_progress = 0.0
