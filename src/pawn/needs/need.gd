class_name Need
extends Node

# Signal declaration
signal value_changed(need_name, old_value, new_value, state)

# Core properties
var current_value: float = 100.0
var max_value: float = 100.0
var min_value: float = 0.0
var need_name: String = "GenericNeed"
var is_paused: bool = false

# Decay rate (amount lost per second)
var decay_rate: float = 0.05

# Thresholds for different states
var thresholds = {
	"critical": 15.0,
	"low": 30.0,
	"satisfied": 70.0,
	"full": 90.0
}

# Owner reference
var pawn = null

func _init(need_name_value: String, initial_value: float = 100.0, decay: float = 0.05):
	need_name = need_name_value
	current_value = initial_value
	decay_rate = decay

func _process(delta):
	if not is_paused:
		# Apply decay over time
		decrease(decay_rate * delta)
	
func pause():
	is_paused = true
	print("is_paused set!")

func resume():
	is_paused = false
	print("is_paused removed!")
	
# Increase the need value (eating food, sleeping)
func increase(amount: float):
	var old_value = current_value
	current_value = min(max_value, current_value + amount)
	#print("Increasing by: ", amount)

	# Emit signal if value changed
	if old_value != current_value:
		emit_signal("value_changed", need_name, old_value, current_value, get_state())


# Decrease the need value (hunger increases, energy decreases)
func decrease(amount: float):
	var old_value = current_value
	current_value = max(min_value, current_value - amount)
	#print("Decreasing by: ", amount)

	# Emit signal if value changed
	if old_value != current_value:
		emit_signal("value_changed", need_name, old_value, current_value, get_state())

# Get the current state based on thresholds
func get_state() -> String:
	if current_value <= thresholds.critical:
		return "critical"
	elif current_value <= thresholds.low:
		return "low"
	elif current_value >= thresholds.full:
		return "full"
	elif current_value >= thresholds.satisfied:
		return "satisfied"
	else:
		return "normal"
		
# Check if this need is at a critical level
func is_critical() -> bool:
	return current_value <= thresholds.critical
	
# Check if this need requires attention
func needs_attention() -> bool:
	return current_value <= thresholds.low
