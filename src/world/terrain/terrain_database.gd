class_name TerrainDatabase
extends Resource


var terrain_definitions = {
	"forest": {
		"base_color": Color.DARK_GREEN,
		"density_range": [0.5, 0.60],
		"walkable": true,
		"movement_cost": 1.5,
		"subterrain": ["dirt", "grass", "deep_grass", "bush", "tree", "tree_stump", "fallen_logs", "mushroom_patch"],
		"subterrain_thresholds": [-0.8, -0.6, -0.4, -0.2, 0.4, 0.7, 0.9],
		"tile_id": [34, 35] # Add tile_id for TileMap rendering
	},
	"swamp": {
		"base_color": Color.DARK_OLIVE_GREEN,
		"density_range": [0.2, 0.3],
		"walkable": true,
		"movement_cost": 2.0,
		"subterrain": ["shallow_water", "mud", "bog", "clay", "moss", "quicksand", "dead_trees"],
		"subterrain_thresholds": [-0.8, -0.6, -0.4, -0.2, 0.2, 0.6, 0.8],
		"tile_id": [19] # Add tile_id for TileMap rendering
	},
	"plains": {
		"base_color": Color.FOREST_GREEN,
		"density_range": [0.3, 0.45],
		"walkable": true,
		"movement_cost": 1.0,
		"subterrain": ["dirt", "grass", "bush", "deep_grass", "tall_grass", "wildflowers", "scrubland", "savanna"],
		"subterrain_thresholds": [-0.8, -0.6, -0.4, -0.2, 0.4, 0.6, 0.8],
		"tile_id": [36] # Add tile_id for TileMap rendering
	},
	"mountain": {
		"base_color": Color(0.6, 0.6, 0.6, 0.6),
		"density_range": [0.60, 1.0],
		"walkable": false,
		"movement_cost": 3.0,
		"subterrain": ["rocky", "peak", "cave", "cliff", "mineral_deposit", "crystal_formation", "arcane_glade"],
		"subterrain_thresholds": [-0.6, -0.3, 0.0, 0.3, 0.6, 0.85, 0.95],
		"tile_id": [28] # Add tile_id for TileMap rendering
	},
	"river": {
		"base_color": Color.DODGER_BLUE,
		"density_range": [0.0, 0.5],
		"walkable": true,
		"movement_cost": 2.5,
		"is_water": true,
		"subterrain": ["shallow_water", "water", "rapids", "riverbank"],
		"subterrain_thresholds": [-0.6, -0.3, 0.0, 0.3],
		"tile_id": [7] # Add tile_id for TileMap rendering
	}
}

var subterrain_definitions = {
	# Forest subterrains
	"tree": {
		"color_modifier": "darkened",
		"color_amount": 0.3,
		"walkable": true,
		"base_color": Color(0.13, 0.55, 0.13),
		"movement_cost": 2.0,
		"tile_id": [0, 1]
	},
	"bush": {
		"color_modifier": "darkened",
		"color_amount": 0.2,
		"walkable": true,
		"base_color": Color(0.18, 0.31, 0.18),
		"movement_cost": 1.8,
		"tile_id": [2]
	},
	"deep_grass": {
		"color_modifier": "darkened",
		"color_amount": 0.1,
		"walkable": true,
		"base_color": Color(0.25, 0.41, 0.25),
		"movement_cost": 1.5,
		"tile_id": [3]
	},
	"grass": {
		"color_modifier": "none",
		"color_amount": 0,
		"walkable": true,
		"movement_cost": 1.0,
		"tile_id": [4]
	},
	"dirt": {
		"base_color": Color.DARK_OLIVE_GREEN,
		"color_modifier": "darkened",
		"color_amount": 0.5,
		"walkable": true,
		"movement_cost": 1.2,
		"tile_id": [5]
	},
	
	# Swamp subterrains
	"shallow_water": {
		"color_modifier": "lightened",
		"color_amount": 0.1,
		"walkable": true,
		"is_water": true,
		"base_color": Color(0.0, 0.5, 0.5),
		"movement_cost": 2.5,
		"tile_id": [6]
	},
	"water": {
		"color_modifier": "darkened",
		"color_amount": 0.2,
		"walkable": false,
		"is_water": true,
		"movement_cost": 0.0,
		"tile_id": [7]
	},
	"mud": {
		"color_modifier": "darkened",
		"color_amount": 0.2,
		"walkable": true,
		"base_color": Color(0.36, 0.25, 0.20),
		"movement_cost": 3.0,
		"tile_id": [8]
	},
	"bog": {
		"color_modifier": "darkened",
		"color_amount": 0.3,
		"walkable": true,
		"base_color": Color(0.25, 0.25, 0.20),
		"movement_cost": 3.5,
		"tile_id": [9]
	},
	"clay": {
		"color_modifier": "darkened",
		"color_amount": 0.5,
		"walkable": true,
		"base_color": Color(0.69, 0.40, 0.20),
		"movement_cost": 2.8,
		"tile_id": [10]
	},
	"moss": {
		"base_color": Color.DARK_OLIVE_GREEN,
		"color_modifier": "lightened",
		"color_amount": 0.1,
		"walkable": true,
		"movement_cost": 1.5,
		"tile_id": [11]
	},
	
	# Mountain subterrains
	"peak": {
		"color_modifier": "darkened",
		"color_amount": 0.2,
		"walkable": false,
		"base_color": Color(0.5, 0.5, 0.5),
		"movement_cost": 0.0,
		"tile_id": [28]
	},
	"rocky": {
		"color_modifier": "lightened",
		"color_amount": 0.1,
		"walkable": true,
		"base_color": Color(0.6, 0.6, 0.6),
		"movement_cost": 2.5,
		"tile_id": [12, 13]
	},
	
	# Plains subterrains
	"tall_grass": {
		"color_modifier": "darkened",
		"color_amount": 0.15,
		"walkable": true,
		"base_color": Color(0.33, 0.42, 0.18),
		"movement_cost": 1.3,
		"tile_id": [14]
	},
	"wildflowers": {
		"color_modifier": "lightened",
		"color_amount": 0.2,
		"walkable": true,
		"base_color": Color(0.85, 0.44, 0.84),
		"movement_cost": 1.1,
		"tile_id": [15, 16, 17, 18]
	},
	"scrubland": {
		"color_modifier": "darkened",
		"color_amount": 0.25,
		"walkable": true,
		"base_color": Color(0.42, 0.26, 0.15),
		"movement_cost": 1.7,
		"tile_id": [19]
	},
	"savanna": {
		"base_color": Color.GOLD,
		"color_modifier": "lightened",
		"color_amount": 0.1,
		"walkable": true,
		"movement_cost": 1.2,
		"tile_id": [20]
	},
	
	# River subterrains
	"rapids": {
		"color_modifier": "lightened",
		"color_amount": 0.3,
		"walkable": false,
		"is_water": true,
		"base_color": Color(0.0, 0.75, 1.0),
		"movement_cost": 0.0,
		"tile_id": [7]
	},
	"riverbank": {
		"color_modifier": "darkened",
		"color_amount": 0.1,
		"walkable": true,
		"base_color": Color(0.54, 0.27, 0.07),
		"movement_cost": 1.4,
		"tile_id": [9, 10, 22]
	},
	
	# Additional forest subterrains
	"fallen_logs": {
		"base_color": Color.SADDLE_BROWN,
		"color_modifier": "darkened",
		"color_amount": 0.4,
		"walkable": true,
		"movement_cost": 2.2,
		"tile_id": [23]
	},
	"mushroom_patch": {
		"base_color": Color.DIM_GRAY,
		"color_modifier": "darkened",
		"color_amount": 0.2,
		"walkable": true,
		"movement_cost": 1.6,
		"tile_id": [24, 25]
	},
	"tree_stump": {
		"base_color": Color.BURLYWOOD,
		"color_modifier": "darkened",
		"color_amount": 0.4,
		"walkable": true,
		"movement_cost": 2.0,
		"tile_id": [26]
	},
	
	# Additional mountain subterrains
	"cave": {
		"color_modifier": "darkened",
		"color_amount": 0.6,
		"walkable": true,
		"base_color": Color(0.2, 0.2, 0.2),
		"movement_cost": 1.0,
		"tile_id": [27]
	},
	"cliff": {
		"color_modifier": "darkened",
		"color_amount": 0.4,
		"walkable": false,
		"base_color": Color(0.4, 0.4, 0.4),
		"movement_cost": 0.0,
		"tile_id": [28]
	},
	"mineral_deposit": {
		"color_modifier": "lightened",
		"color_amount": 0.3,
		"walkable": true,
		"base_color": Color(0.8, 0.8, 0.0),
		"movement_cost": 2.8,
		"tile_id": [31]
	},
	
	# Additional swamp subterrains
	"quicksand": {
		"base_color": Color.SANDY_BROWN,
		"color_modifier": "darkened",
		"color_amount": 0.3,
		"movement_cost": 25.0,
		"walkable": true,
		"tile_id": [19]
	},
	"dead_trees": {
		"color_modifier": "darkened",
		"color_amount": 0.5,
		"walkable": true,
		"base_color": Color(0.36, 0.25, 0.20),
		"movement_cost": 2.5,
		"tile_id": [30]
	},
	
	"crystal_formation": {
		"base_color": Color.AQUA,
		"color_modifier": "lightened",
		"color_amount": 0.4,
		"walkable": true,
		"movement_cost": 2.0,
		"tile_id": [32]
	},

	# Magic-influenced subterrains
	"arcane_glade": {
		"base_color": Color.MEDIUM_PURPLE,
		"color_modifier": "lightened",
		"color_amount": 0.3,
		"walkable": true,
		"movement_cost": 1.8,
		"tile_id": [33]
	}
}

# For Map Generation and TileSet
func get_terrain_tile_id(terrain_type):
	if terrain_type in terrain_definitions:
		# Return source_id 0 for main terrain types
		return {"source_id": 0, "coords": terrain_definitions[terrain_type].tile_id[randi() % terrain_definitions[terrain_type].tile_id.size()]}
	return {"source_id": 0, "coords": 0} # Default fallback

func get_subterrain_tile_id(subterrain_type):
	if subterrain_type in subterrain_definitions:
		# Return source_id 1 for subterrain variations
		return {"source_id": 0, "coords": subterrain_definitions[subterrain_type].tile_id[randi() % subterrain_definitions[subterrain_type].tile_id.size()]}
	return {"source_id": 0, "coords": 0} # Default fallback


# Get terrain type based on density value
func get_terrain_type(density: float) -> String:
	for terrain_type in terrain_definitions:
		var range_values = terrain_definitions[terrain_type].density_range
		if range_values.size() == 2:
			if density >= range_values[0] and density < range_values[1]:
				return terrain_type
	return "plains" # Default

# Get subterrain based on terrain type and detail value
func get_subterrain(terrain_type: String, detail_val: float) -> String:
	# If terrain doesn't exist in definitions, return default
	if not terrain_type in terrain_definitions:
		return "grass"
		
	# Get subterrains and thresholds for this terrain type
	var terrain = terrain_definitions[terrain_type]
	var subterrains = terrain.subterrain
	
	# If no subterrains defined, return empty
	if subterrains.size() == 0:
		return ""
	
	# Use thresholds to determine which subterrain to use
	if "subterrain_thresholds" in terrain:
		var thresholds = terrain.subterrain_thresholds
		for i in range(thresholds.size()):
			if detail_val < thresholds[i]:
				return subterrains[i]
		# If we pass all thresholds, return the last subterrain
		return subterrains[subterrains.size() - 1]
	
	# Default to first subterrain if no thresholds are defined
	return subterrains[0]

# Apply color modification based on subterrain
func get_modified_color(base_color: Color, subterrain: String) -> Color:
	if not subterrain in subterrain_definitions:
		return base_color
		
	var subterrain_def = subterrain_definitions[subterrain]
	
	# If subterrain has custom base color, use that instead
	if subterrain_def.has("base_color"):
		return subterrain_def.base_color
	
	# Apply color modifier
	match subterrain_def.color_modifier:
		"darkened":
			return base_color.darkened(subterrain_def.color_amount)
		"lightened":
			return base_color.lightened(subterrain_def.color_amount)
		_:
			return base_color

# Check if a subterrain is walkable
func is_walkable(terrain_type: String, subterrain: String) -> bool:
	# Check subterrain walkability first
	if subterrain in subterrain_definitions and subterrain_definitions[subterrain].has("walkable"):
		return subterrain_definitions[subterrain].walkable
	
	# Fall back to terrain walkability
	if terrain_type in terrain_definitions and terrain_definitions[terrain_type].has("walkable"):
		return terrain_definitions[terrain_type].walkable
	
	return true # Default to walkable
