# HarvestingJob.gd
class_name HarvestingJob
extends Resource

var target_position = Vector2i() # Grid position of the resource
var resource_type = "" # Type of resource to harvest
var amount_available = 0 # Amount available to harvest
var time_to_harvest = 2.0 # Time in seconds to harvest
var progress = 0.0 # Current progress (0.0 to 1.0)
var assigned_pawn = null # Reference to the assigned pawn

func _init(pos, type, amount, time = 2.0):
    target_position = pos
    resource_type = type
    amount_available = amount
    time_to_harvest = time

func is_complete():
    return progress >= 1.0
