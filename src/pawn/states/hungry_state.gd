class_name HungryState
extends PawnState

func _init():
    var state_name = "Hungry"

func enter():
    print("Pawn " + str(pawn.pawn_id) + " is hungry and looking for food")
    find_food()

func find_food():
    # Find the nearest food source
    var food_position = find_nearest_food_source()
    
    if food_position:
        # Create an eating job
        pawn.current_job = EatingJob.new(food_position, "food", 1, 2.0)
        
        # Change to MovingToNeed state
        state_machine.change_state("MovingToNeed")
    else:
        print("No food found!")
        state_machine.change_state("Idle")

func find_nearest_food_source():
    # This would search the map for food sources
    # For now, return a placeholder position
    # In the future, this would use your map data to find actual food
    return Vector2i(10, 10) # Placeholder
