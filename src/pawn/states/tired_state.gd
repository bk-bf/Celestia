class_name TiredState
extends PawnState

func _init():
    var state_name = "Tired"

func enter():
    print("Pawn " + str(pawn.pawn_id) + " is tired and looking for a place to rest")
    find_rest_place()

func find_rest_place():
    # Find the nearest rest place
    var rest_position = find_nearest_rest_place()
    
    if rest_position:
        # Create a sleeping job
        pawn.current_job = SleepingJob.new(rest_position, "simple_spot", 1, 5.0)
        
        # Change to MovingToNeed state
        state_machine.change_state("MovingToNeed")
    else:
        print("No rest place found!")
        state_machine.change_state("Idle")

func find_nearest_rest_place():
    # This would search the map for rest places
    # For now, return a placeholder position
    # In the future, this would use your map data to find actual beds
    return Vector2i(15, 15) # Placeholder
