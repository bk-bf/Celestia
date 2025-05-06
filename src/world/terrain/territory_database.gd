class_name TerritoryDatabase
extends Resource

var territory_definitions = {
    "wolfs": {
        "territory_thresholds": [0.3, 0.7],
        "preferred_terrain": ["forest"],
        "color": Color.BLACK,
        "rarity": 100, # the higher the more common
		"coexistence_layer": 1 # territories with the same number can overlap
    },
    "bears": {
        "territory_thresholds": [0.7, 1.1],
        "preferred_terrain": ["mountain"],
        "color": Color.ORANGE,
        "rarity": 100,
		"coexistence_layer": 2
    },
    "goblins": {
        "territory_thresholds": [1.1, 1.5],
        "preferred_terrain": ["swamp"],
        "color": Color.PURPLE,
        "rarity": 99,
		"coexistence_layer": 1
    },
    "drakes": {
        "territory_thresholds": [1.5, 1.9],
        "preferred_terrain": ["mountain"],
        "color": Color.SEA_GREEN,
        "rarity": 10,
		"coexistence_layer": 3
    },
    "orcs": {
        "territory_thresholds": [1.3, 1.7],
        "preferred_terrain": ["forest"],
        "color": Color.DIM_GRAY,
        "rarity": 98,
		"coexistence_layer": 1
    },
    "pigman": {
        "territory_thresholds": [0.4, 0.8],
        "preferred_terrain": ["plains"],
        "color": Color.PINK,
        "rarity": 100,
		"coexistence_layer": 3
    },
    "slime": {
        "territory_thresholds": [0.2, 0.6],
        "preferred_terrain": ["plains", "forest"],
        "color": Color.SKY_BLUE,
        "rarity": 99,
		"coexistence_layer": 1
    },
    "kobolds": {
        "territory_thresholds": [0.5, 0.9],
        "preferred_terrain": ["plains", "forest"],
        "color": Color.YELLOW,
        "rarity": 99,
		"coexistence_layer": 1
    },
    "spiders": {
        "territory_thresholds": [1.2, 1.6],
        "preferred_terrain": ["plains"],
        "color": Color.BLACK,
        "rarity": 50,
		"coexistence_layer": 100
    },
    "bandits": {
        "territory_thresholds": [0.6, 1.0],
        "preferred_terrain": ["forest", "mountain"],
        "color": Color.RED,
        "rarity": 90,
		"coexistence_layer": 99
    },
	"river_ghouls": {
        "territory_thresholds": [0.6, 1.0],
        "preferred_terrain": ["river"],
        "color": Color.LIME_GREEN,
        "rarity": 10,
		"coexistence_layer": 101
	}
}


# ALL THIS SHIT HAS TO BE MOVED EVENTUALLY
func get_monster_data(monster_type: String) -> Dictionary:
	if monster_type in territory_definitions:
		return territory_definitions[monster_type]
	return {}

func get_territory_frequency(monster_type: String) -> float:
	if monster_type in territory_definitions:
		return territory_definitions[monster_type].territory_frequency
	return 0.05 # Default frequency

func get_territory_thresholds(monster_type: String) -> Array:
	if monster_type in territory_definitions:
		return territory_definitions[monster_type].territory_thresholds
	return [0.4, 0.6]
	
func get_monster_types() -> Array:
	return territory_definitions.keys()
