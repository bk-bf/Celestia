extends Node

class_name TraitDatabase

# Dictionary to store all trait definitions
var traits = {
    # Disposition Traits
    "stoic": {
        "category": "disposition",
        "effects": {"negative_mood_impact": 0.85, "positive_mood_impact": 0.9},
        "conditions": {},
        "description": "Reduces impact of negative mood events by 15% and positive ones by 10%."
    },
    "whimsical": {
        "category": "disposition",
        "effects": {"creative_mood_bonus": 1.05, "beauty_mood_bonus": 1.1},
        "conditions": {"task_type": "creative"},
        "description": "Increases mood by 5% during creative tasks and when witnessing beauty."
    },
    "contemplative": {
        "category": "disposition",
        "effects": {"research_speed": 1.1, "crowded_mood": 0.95},
        "conditions": {"is_alone": true},
        "description": "Increases research speed by 10% when alone, -5% mood in crowded areas."
    },
	"optimist": {
		"category": "disposition",
		"effects": {
			"positive_mood_multiplier": 1.5,
			"negative_mood_multiplier": 0.5
		},
		"conditions": {},
		"description": "Sees the bright side of everything. Positive mood effects are 50% stronger, negative mood effects are 50% weaker."
	},
	"pessimist": {
		"category": "disposition",
		"effects": {
			"positive_mood_multiplier": 0.5,
			"negative_mood_multiplier": 1.5
		},
		"conditions": {},
		"description": "Always expects the worst. Positive mood effects are 50% weaker, negative mood effects are 50% stronger."
	},

	# Learning Traits
	"inquisitive": {
		"category": "learning",
		"effects": {"low_skill_learning": 1.15, "high_skill_learning": 0.95},
		"conditions": {},
		"description": "Increases learning rate by 15% for skills below level 5, -5% for higher skills."
	},
	"methodical": {
		"category": "learning",
		"effects": {"learning_rate": 0.9, "skill_retention": 1.2},
		"conditions": {},
		"description": "Decreases learning rate by 10%, but improves skill retention by 20%."
	},
	"observant": {
		"category": "learning",
		"effects": {"learning_from_skilled": 1.05},
		"conditions": {"near_higher_skill": true},
		"description": "Increases learning rate by 5% when working with higher-skilled pawns."
	},
	
	# Specialization Traits
	"nimble_fingers": {
		"category": "specialization",
		"effects": {"crafting_skill": 2, "detailed_work_speed": 1.1},
		"conditions": {"task_type": "crafting"},
		"description": "Adds +2 to Crafting skill and 10% work speed with detailed items."
	},
	"naturalist": {
		"category": "specialization",
		"effects": {"farming_skill": 2, "harvest_yield": 1.15},
		"conditions": {"task_type": "harvesting"},
		"description": "Adds +2 to Farming skill and 15% yield when harvesting plants."
	},
	"tactician": {
		"category": "specialization",
		"effects": {"combat_skill": 2, "ranged_damage": 1.1},
		"conditions": {"weapon_type": "ranged"},
		"description": "Adds +2 to Combat skills and 10% damage with ranged weapons."
	},
	
	# Social Interaction Traits
	"reserved": {
		"category": "social",
		"effects": {"social_impact": 0.85, "manipulation_resistance": 1.1},
		"conditions": {},
		"description": "Reduces social impact by 15%, increases resistance to manipulation by 10%."
	},
	"diplomatic": {
		"category": "social",
		"effects": {"faction_relations": 1.1},
		"conditions": {"task_type": "negotiation"},
		"description": "Improves faction relationship gains by 10% during negotiations."
	},
	"empathetic": {
		"category": "social",
		"effects": {"mood_detection": 1.2, "mood_boost_aura": 1.05},
		"conditions": {"nearby_distressed": true},
		"description": "Improves mood detection and provides 5% mood boost to distressed pawns."
	},
	
	# Romantic Interaction Traits
	"devoted": {
		"category": "romantic",
		"effects": {"relationship_strength": 1.2, "attraction_time": 1.5},
		"conditions": {},
		"description": "Increases relationship strength by 20% but takes 50% longer to develop attraction."
	},
	"flirtatious": {
		"category": "romantic",
		"effects": {"romance_frequency": 1.3, "relationship_depth": 0.9},
		"conditions": {},
		"description": "Initiates romantic interactions 30% more often but with 10% less depth."
	},
	"independent": {
		"category": "romantic",
		"effects": {"romance_need": 0.75, "solo_mood": 1.15},
		"conditions": {"task_type": "solo"},
		"description": "Reduces need for romantic interaction by 25%, +15% mood for solo work."
	},
	
	# Productivity Traits
	"focused": {
		"category": "productivity",
		"effects": {"work_speed": 1.15},
		"conditions": {"same_task_hours": 2},
		"description": "Increases work speed by 15% when on same task for over 2 hours."
	},
	"adaptable": {
		"category": "productivity",
		"effects": {"task_switch_penalty": 0.9},
		"conditions": {},
		"description": "Reduces penalty by 10% when switching between different work types."
	},
	"meticulous": {
		"category": "productivity",
		"effects": {"quality_chance": 1.2, "work_speed": 0.9},
		"conditions": {},
		"description": "Increases quality chance by 20% but reduces work speed by 10%."
	},
	
	# Preference Traits
	"early_riser": {
		"category": "preference",
		"effects": {"morning_work_speed": 1.1, "night_work_speed": 0.95},
		"conditions": {"time_of_day": "morning"},
		"description": "Increases work speed by 10% during morning, -5% during night."
	},
	"outdoorsy": {
		"category": "preference",
		"effects": {"outdoor_mood": 1.1, "indoor_mood": 0.95},
		"conditions": {"location": "outside"},
		"description": "Increases mood by 10% when outside, -5% when indoors for long periods."
	},
	"ascetic": {
		"category": "preference",
		"effects": {"simple_mood": 1.1, "luxury_mood": 0.95},
		"conditions": {"surroundings": "simple"},
		"description": "Increases mood by 10% in simple conditions, -5% in luxury."
	},
	
	# Combat Traits
	"berserker": {
		"category": "combat",
		"effects": {"melee_damage": 1.15, "dodge_chance": 0.95},
		"conditions": {"health_percentage_below": 0.5},
		"description": "Increases melee damage by 15% when below 50% health, -5% dodge chance."
	},
	"sharpshooter": {
		"category": "combat",
		"effects": {"ranged_accuracy": 1.2, "firing_speed": 0.9},
		"conditions": {"target_distance_above": 10},
		"description": "Increases accuracy by 20% beyond 10 tiles, -10% firing speed."
	},
	"spellweaver": {
		"category": "combat",
		"effects": {"spell_mana_cost": 0.85},
		"conditions": {"consecutive_same_element": true},
		"description": "Reduces mana cost by 15% when casting consecutive spells of same element."
	},
	
	# Exploration Traits
	"eagle_eyed": {
		"category": "exploration",
		"effects": {"vision_range": 1.2},
		"conditions": {"time_of_day": "day"},
		"description": "Increases vision range by 20% during daylight hours."
	},
	"pathfinder": {
		"category": "exploration",
		"effects": {"wilderness_speed": 1.15, "territory_alert_chance": 0.9},
		"conditions": {"terrain_type": "wilderness"},
		"description": "Increases movement speed by 15% in wilderness, -10% chance to trigger monster alerts."
	},
	"night_owl": {
		"category": "exploration",
		"effects": {"night_vision": 1.15, "day_vision": 0.95},
		"conditions": {"time_of_day": "night"},
		"description": "Increases vision range by 15% at night, -5% during day."
	},
	
	# Class Affinity Traits
	"arcane_affinity": {
		"category": "class_affinity",
		"effects": {"magic_learning": 1.1, "spell_mana_cost": 0.95},
		"conditions": {},
		"description": "Increases magical skill learning by 10%, reduces spell mana cost by 5%."
	},
	"warrior_spirit": {
		"category": "class_affinity",
		"effects": {"melee_damage": 1.1},
		"conditions": {"armor_type": "heavy"},
		"description": "Increases melee damage by 10% when wearing heavy armor."
	},
	"hunters_instinct": {
		"category": "class_affinity",
		"effects": {"critical_chance": 1.15},
		"conditions": {"target_aware": false},
		"description": "Increases critical hit chance by 15% against unaware targets."
	},
	
	# Monster Interaction Traits
	"beast_whisperer": {
		"category": "monster_interaction",
		"effects": {"pacify_chance": 1.15, "monster_intention_detection": 1.2},
		"conditions": {"monster_type": "non_aggressive"},
		"description": "Increases chance to pacify non-aggressive monsters by 15%, better intention detection."
	},
	"monster_hunter": {
		"category": "monster_interaction",
		"effects": {"monster_damage": 1.1, "weakness_detection": true},
		"conditions": {"monster_type": "territorial"},
		"description": "Increases damage against territorial monsters by 10%, can identify weaknesses."
	},
	"fearless": {
		"category": "monster_interaction",
		"effects": {"fear_immunity": true, "dodge_chance": 0.95},
		"conditions": {},
		"description": "Immune to monster fear effects, -5% dodge chance due to reduced caution."
	},
	
	# Weapon Preference Traits
	"bowmaster": {
		"category": "weapon_preference",
		"effects": {"archery_skill": 2, "bow_draw_speed": 1.1},
		"conditions": {"weapon_type": "bow"},
		"description": "Adds +2 to Archery skill, increases bow draw speed by 10%."
	},
	"axe_enthusiast": {
		"category": "weapon_preference",
		"effects": {"axe_skill": 2, "bleeding_chance": 1.15},
		"conditions": {"weapon_type": "axe"},
		"description": "Adds +2 to Axe skill, increases bleeding chance by 15% with axes."
	},
	"sword_dancer": {
		"category": "weapon_preference",
		"effects": {"sword_skill": 2, "dodge_chance": 1.1},
		"conditions": {"weapon_type": "sword"},
		"description": "Adds +2 to Sword skill, increases dodge chance by 10% with swords."
	},
	
	# Genetic Traits
	"eagle_eyed_genetic": {
		"category": "genetic",
		"effects": {"vision_range": 1.2},
		"conditions": {"time_of_day": "day"},
		"description": "Increases vision range by 20% during daylight, no benefit at night."
	},
	"freerunner": {
		"category": "genetic",
		"effects": {"difficult_terrain_penalty": 0.7, "movement_speed": 1.1},
		"conditions": {},
		"description": "Reduces movement penalty on difficult terrain by 30%, +10% general speed."
	},
	"night_vision": {
		"category": "genetic",
		"effects": {"night_vision_range": 1.25, "bright_vision_range": 0.95},
		"conditions": {"time_of_day": "night"},
		"description": "Increases vision range by 25% at night, -5% during bright daylight."
	},
	
	# Legendary Traits
	"chosen_one": {
		"category": "legendary",
		"effects": {"fatal_survival": true},
		"conditions": {"once_per_day": true},
		"description": "Once per day, automatically survive a fatal blow with 10% health remaining."
	},
	"dragonblood": {
		"category": "legendary",
		"effects": {"elemental_resistance": 1.5, "flame_burst": true},
		"conditions": {"stress_level": "high"},
		"description": "Provides 50% resistance to elemental damage, occasional flame bursts when stressed."
	},
	"timeless": {
		"category": "legendary",
		"effects": {"aging_rate": 0.5, "learning_rate": 1.2},
		"conditions": {},
		"description": "Aging occurs at half the normal rate, +20% to all learning rates."
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
