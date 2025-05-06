extends Node

var pawn_manager = null

func _ready():
    # Find the PawnManager when the game starts
    pawn_manager = get_node("/root/Game/Main/PawnManager")
