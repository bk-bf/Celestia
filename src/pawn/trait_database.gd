extends Node

class_name TraitDatabase

# Dictionary to store all trait definitions
var traits = {

	# Exploration Traits
    "eagle_eyed": {
        "category": "exploration",
        "effects": {"vision_range": 1.2},
        "conditions": {"time_of_day": "day"}, # time and day/night cycle not yet implemented
        "description": "Increases vision range by 20% during daylight hours."
    },

	# Combat Traits
    "berserker": {
        "category": "combat",
        "effects": {"melee_damage": 1.15},
        "conditions": {"health_percentage_below": 0.5},
        "description": "Increases melee damage by 15% when below 50% health."
    },

	# Productivity Traits
    "focused": {
        "category": "productivity",
        "effects": {"work_speed": 1.15},
        "conditions": {"same_task_hours": 2},
        "description": "Increases work speed by 15% when working on the same task for more than 2 hours."
    }
}

# Function to get a trait by name
func get_trait(trait_name):
    if traits.has(trait_name):
        return traits[trait_name]
    return null

# Function to get all traits in a category
func get_traits_by_category(category):
    var result = {}
    for trait_name in traits.keys():
        if traits[trait_name]["category"] == category:
            result[trait_name] = traits[trait_name]
    return result
