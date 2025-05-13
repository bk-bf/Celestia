# EatingJob.gd
class_name EatingJob
extends Job

var nutrition_value: float = 20.0 # Base nutrition provided by this food

func _init(position, food_type, amount, time_required):
    super._init(position, food_type, amount, time_required)
    type = "eating"

func complete():
    # Give nutrition to the pawn
    if assigned_pawn:
        assigned_pawn.needs["hunger"].increase(nutrition_value)
        print("Pawn " + str(assigned_pawn.pawn_id) + " satisfied hunger by " + str(nutrition_value))
    return true
