class_name TerritoryDatabase
extends Resource

var territory_definitions = {
	
	
	"wolf_pack": {
		"territory_thresholds": [0.3, 0.7], 
		"preferred_terrain": ["forest"],
		"color": Color.RED,
	},
	"bear_den": {
		"territory_thresholds": [0.7, 1.1], 
		"preferred_terrain": ["mountain"],
		"color": Color.ORANGE,
	},
	"goblin_tribe": {
		"territory_thresholds": [1.1, 1.5], 
		"preferred_terrain": ["swamp"],

		"color": Color.PURPLE,
	},
	"drake_nest": {
		"territory_thresholds": [1.5, 1.9],
		"preferred_terrain": ["mountain"],
		"color": Color.BLUE,
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
