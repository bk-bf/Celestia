class_name MoodManager
extends Node

# Signal for mood changes
signal mood_changed(old_value, new_value, mood_state)

# Core properties
var current_mood: float = 50.0 # Start at neutral mood (0-100 scale)
var max_mood: float = 100.0
var min_mood: float = 0.0

# Owner reference
var pawn = null

# Thresholds for different mood states
var thresholds = {
    "depressed": 15.0, # Below this is depressed
    "sad": 30.0, # Below this is sad
    "neutral": 50.0, # Below this is neutral
    "happy": 75.0, # Above this is happy
    "ecstatic": 90.0 # Above this is ecstatic
}

# Mood modifiers storage
var active_modifiers = {}
var temporary_modifiers = {} # Modifiers with duration {id: {value: X, duration: Y}}

# Initialize the mood system
func _init(pawn_reference):
    pawn = pawn_reference

func _process(delta):
    # Process temporary modifiers
    var modifiers_to_remove = []
    
    for modifier_id in temporary_modifiers:
        temporary_modifiers[modifier_id].duration -= delta
        if temporary_modifiers[modifier_id].duration <= 0:
            modifiers_to_remove.append(modifier_id)
    
    # Remove expired modifiers
    for modifier_id in modifiers_to_remove:
        remove_modifier(modifier_id)
    
    # Gradually trend mood toward neutral if no strong modifiers exist
    if active_modifiers.size() == 0 and temporary_modifiers.size() == 0:
        if current_mood > thresholds.neutral:
            decrease(0.1 * delta) # Slowly decrease if above neutral
        elif current_mood < thresholds.neutral:
            increase(0.1 * delta) # Slowly increase if below neutral
    
    # Check for situation-specific mood effects
    check_environment_effects()
    check_activity_effects()

# Add a mood modifier from a trigger, applying trait effects
func add_mood_from_trigger(trigger_name):
    var mood_db = DatabaseManager.mood_database
    var trigger = mood_db.get_trigger_for_pawn(trigger_name, pawn)
    
    if trigger:
        if trigger.duration > 0:
            add_temporary_modifier(trigger_name, trigger.value, trigger.duration, trigger.description)
        else:
            add_modifier(trigger_name, trigger.value, trigger.description)

# Check for environment-related mood effects
func check_environment_effects():
    # Check for crowded environment (for contemplative trait)
    var nearby_pawns = count_nearby_pawns(5) # 5 tile radius
    if nearby_pawns > 3: # More than 3 pawns nearby is considered crowded
        add_mood_from_trigger("crowded_environment")
    
    # Check for beautiful environment (for whimsical trait)
    if is_in_beautiful_environment():
        add_mood_from_trigger("beautiful_environment")

# Check for activity-related mood effects
func check_activity_effects():
    # Check for creative tasks (for whimsical trait)
    if pawn.current_job and pawn.current_job.type in ["art", "crafting", "research"]:
        add_mood_from_trigger("performing_creative_task")

# Helper functions
func count_nearby_pawns(radius):
    # Implementation to count pawns within radius
    return 0 # Placeholder

func is_in_beautiful_environment():
    # Implementation to check if environment is beautiful
    return false # Placeholder

# Add a persistent mood modifier
func add_modifier(id: String, value: float, description: String = ""):
    var old_mood = current_mood
    active_modifiers[id] = {
        "value": value,
        "description": description
    }
    
    # Apply the immediate effect
    if value > 0:
        increase(value)
    else:
        decrease(abs(value))
        
    emit_signal("mood_changed", old_mood, current_mood, get_mood_state())

# Add a temporary mood modifier
func add_temporary_modifier(id: String, value: float, duration: float, description: String = ""):
    var old_mood = current_mood
    temporary_modifiers[id] = {
        "value": value,
        "duration": duration,
        "description": description
    }
    
    # Apply the immediate effect
    if value > 0:
        increase(value)
    else:
        decrease(abs(value))
        
    emit_signal("mood_changed", old_mood, current_mood, get_mood_state())

# Remove a mood modifier
func remove_modifier(id: String):
    var old_mood = current_mood
    
    # Check if it's a persistent modifier
    if active_modifiers.has(id):
        # Reverse the effect
        var value = active_modifiers[id].value
        if value > 0:
            decrease(value)
        else:
            increase(abs(value))
        active_modifiers.erase(id)
    
    # Check if it's a temporary modifier
    if temporary_modifiers.has(id):
        # Reverse the effect
        var value = temporary_modifiers[id].value
        if value > 0:
            decrease(value)
        else:
            increase(abs(value))
        temporary_modifiers.erase(id)
    
    emit_signal("mood_changed", old_mood, current_mood, get_mood_state())

# Decrease mood value
# duplicaaaateees!!!!
func decrease(amount: float):
    var old_value = current_mood
    current_mood = max(min_mood, current_mood - amount)
    
    # Emit signal if value changed
    if old_value != current_mood:
        emit_signal("mood_changed", old_value, current_mood, get_mood_state())

# Increase mood value
func increase(amount: float):
    var old_value = current_mood
    current_mood = min(max_mood, current_mood + amount)
    
    # Emit signal if value changed
    if old_value != current_mood:
        emit_signal("mood_changed", old_value, current_mood, get_mood_state())

# Get the current mood state based on thresholds
func get_mood_state() -> String:
    if current_mood <= thresholds.depressed:
        return "depressed :<"
    elif current_mood <= thresholds.sad:
        return "sad :("
    elif current_mood <= thresholds.neutral:
        return "neutral :|"
    elif current_mood <= thresholds.happy:
        return "happy :)"
    else:
        return "ecstatic :}"

func update_from_needs():
    # Remove previous need-based modifiers
    if active_modifiers.has("hunger_satisfied"):
        remove_modifier("hunger_satisfied")
    if active_modifiers.has("hunger_critical"):
        remove_modifier("hunger_critical")
    if active_modifiers.has("rest_satisfied"):
        remove_modifier("rest_satisfied")
    if active_modifiers.has("rest_critical"):
        remove_modifier("rest_critical")
    
    # Check hunger status
    if pawn.needs.has("hunger"):
        var hunger_need = pawn.needs["hunger"]
        if hunger_need.current_value >= hunger_need.thresholds.satisfied:
            add_modifier("hunger_satisfied", 5.0, "Well-fed")
        elif hunger_need.current_value <= hunger_need.thresholds.critical:
            add_modifier("hunger_critical", -10.0, "Starving")
    
    # Check rest status
    if pawn.needs.has("rest"):
        var rest_need = pawn.needs["rest"]
        if rest_need.current_value >= rest_need.thresholds.satisfied:
            add_modifier("rest_satisfied", 5.0, "Well-rested")
        elif rest_need.current_value <= rest_need.thresholds.critical:
            add_modifier("rest_critical", -10.0, "Exhausted")
