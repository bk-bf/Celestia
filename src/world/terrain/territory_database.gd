# monsters_database.gd
class_name TerritoryDatabase
extends Resource

var territory_definitions = {
	"wolf_pack": {
		"territory_frequency": 0.08,
		"territory_threshold": 0.25,
		"preferred_terrain": "forest",
		"color": Color.DARK_RED,
	},
	"bear_den": {
		"territory_frequency": 0.01,
		"territory_threshold": 0.2,
		"preferred_terrain": "mountain",
		"color": Color.SADDLE_BROWN,
	},
	"goblin_tribe": {
		"territory_frequency": 0.02,
		"territory_threshold": 0.3,
		"preferred_terrain": "swamp",
		"color": Color.WEB_PURPLE,
	},
	"drake_nest": {
		"territory_frequency": 0.05,
		"territory_threshold": 0.35,
		"preferred_terrain": "mountain",
		"color": Color.BLUE_VIOLET,
	}
}

func get_monster_data(monster_type: String) -> Dictionary:
	if monster_type in territory_definitions:
		return territory_definitions[monster_type]
	return {}

func get_territory_frequency(monster_type: String) -> float:
	if monster_type in territory_definitions:
		return territory_definitions[monster_type].territory_frequency
	return 0.05 # Default frequency

func get_territory_threshold(monster_type: String) -> float:
	if monster_type in territory_definitions:
		return territory_definitions[monster_type].territory_threshold
	return 0.6 # Default threshold
	
func get_monster_types() -> Array:
	return territory_definitions.keys()
