class_name MoodDatabase
extends Resource

# Singleton pattern
static var instance = null

# Dictionary to store mood triggers and their effects
var mood_triggers = {
    # Basic need-related triggers
    "hunger_satisfied": {"value": 5.0, "duration": 0.0, "description": "Well-fed"},
    "hunger_critical": {"value": - 10.0, "duration": 0.0, "description": "Starving"},
    "rest_satisfied": {"value": 5.0, "duration": 0.0, "description": "Well-rested"},
    "rest_critical": {"value": - 10.0, "duration": 0.0, "description": "Exhausted"},
    
    # Activity-related triggers
    "job_completed": {"value": 2.0, "duration": 300.0, "description": "Completed a job"},
    "witnessed_death": {"value": - 5.0, "duration": 600.0, "description": "Witnessed death"},
    "ate_fine_meal": {"value": 3.0, "duration": 300.0, "description": "Ate a fine meal"},
    "slept_comfortably": {"value": 2.0, "duration": 300.0, "description": "Slept comfortably"},
    
    # Environment-related triggers (for whimsical and contemplative traits)
    "comfortable_surroundings": {"value": 1.0, "duration": 0.0, "description": "Comfortable surroundings"},
    "uncomfortable_surroundings": {"value": - 2.0, "duration": 0.0, "description": "Uncomfortable surroundings"},
    "beautiful_environment": {"value": 2.0, "duration": 300.0, "description": "Witnessed beauty"},
    "crowded_environment": {"value": - 2.0, "duration": 0.0, "description": "Crowded environment"},
    
    # Creative task triggers (for whimsical trait)
    "performing_creative_task": {"value": 1.0, "duration": 0.0, "description": "Engaged in creative work"}
}

func _init():
    if instance == null:
        instance = self
    else:
        push_error("MoodDatabase already exists!")

static func get_instance():
    if instance == null:
        instance = MoodDatabase.new()
    return instance

# Get a mood trigger with its base values
func get_trigger(trigger_name):
    if mood_triggers.has(trigger_name):
        return mood_triggers[trigger_name].duplicate()
    return null

# Get a mood trigger adjusted for a pawn's traits
func get_trigger_for_pawn(trigger_name, pawn):
    var trigger = get_trigger(trigger_name)
    if trigger == null:
        return null
    
    # Get the trait database
    var trait_db = DatabaseManager.trait_database
    var trigger_value = trigger.value
    
    # Apply trait-specific modifiers
    for trait_name in pawn.traits:
        var trait_data = trait_db.get_trait(trait_name)
        if trait_data == null:
            continue
        
        # Handle specific trait effects
        match trait_name:
            "stoic":
                # Stoic reduces positive and negative mood impacts
                if trigger_value > 0:
                    trigger_value *= trait_data.effects.positive_mood_impact
                else:
                    trigger_value *= trait_data.effects.negative_mood_impact
                    
            "whimsical":
                # Whimsical increases mood for beauty and creative tasks
                if trigger_name == "beautiful_environment":
                    trigger_value *= trait_data.effects.beauty_mood_bonus
                elif trigger_name == "performing_creative_task":
                    trigger_value *= trait_data.effects.creative_mood_bonus
                    
            "contemplative":
                # Contemplative affects mood in crowded environments
                if trigger_name == "crowded_environment":
                    trigger_value *= trait_data.effects.crowded_mood
                    
            "optimist", "pessimist":
                # Optimist/Pessimist affect all mood values based on whether they're positive or negative
                if trigger_value > 0 and trait_data.effects.has("positive_mood_multiplier"):
                    trigger_value *= trait_data.effects.positive_mood_multiplier
                elif trigger_value < 0 and trait_data.effects.has("negative_mood_multiplier"):
                    trigger_value *= trait_data.effects.negative_mood_multiplier
    
    # Update the trigger value
    trigger.value = trigger_value
    return trigger
