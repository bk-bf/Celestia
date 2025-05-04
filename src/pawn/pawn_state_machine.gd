class_name PawnStateMachine
extends Node

var states = {}
var current_state = null
var pawn = null

var debug_mode = false # Set to true only when debugging

func _init(pawn_reference):
	pawn = pawn_reference

func _process(delta):
	if debug_mode:
		print("PawnStateMachine processing state:", current_state)
	if current_state != null:
		states[current_state].update(delta)

func add_state(state_name, state_instance):
	states[state_name] = state_instance
	state_instance.state_machine = self
	state_instance.pawn = pawn
	add_child(state_instance)

func change_state(new_state):
	if current_state != null:
		states[current_state].exit()
   
	if new_state in states: # Make sure the state exists
		current_state = new_state
		states[current_state].enter()
		# debug
		print("Changing state to: " + new_state)
	else:
		print("ERROR: State " + new_state + " not found in state machine")
