# tile_data.gd
class_name TerrainDatabase
extends Resource

var terrain_definitions = {
	"forest": {
		"base_color": Color.DARK_GREEN,
		"density_range": [0.2, 0.6],
		"walkable": true,
		"subterrain": ["dirt", "grass", "bush", "deep_grass", "tree"],
		"subterrain_thresholds": [-0.6, -0.2, 0.2, 0.6]  # Thresholds that determine subterrain
	},
	"swamp": {
		"base_color": Color.DARK_OLIVE_GREEN,
		"density_range": [-0.2, 0.2],
		"walkable": true,
		"subterrain": ["shallow_water", "mud", "bog", "clay", "moss"],
		"subterrain_thresholds": [-0.6, -0.2, 0.2, 0.6]
	},
	"plains": {
		"base_color": Color.FOREST_GREEN,
		"density_range": [-0.2, 0.2],
		"walkable": true,
		"subterrain": ["grass", "bush", "deep_grass", "tree"],
		"subterrain_thresholds": [-0.6, -0.2, 0.2, 0.6]
	},
	"mountain": {
		"base_color": Color(0.6, 0.6, 0.6, 0.6),
		"density_range": [0.6, 1.0],
		"walkable": false,
		"subterrain": ["rocky", "peak"],
		"subterrain_thresholds": [-0.3]  # Just one threshold for mountains
	},
	"river": {
		"base_color": Color.DODGER_BLUE,
		"density_range": [-0.2, -1.0],
		"walkable": true,
		"is_water": true,
		"subterrain": ["shallow water", "water"],
		"subterrain_thresholds": [-0.3]  
	}
}

var subterrain_definitions = {
	# Forest subterrains
	"tree": {
		"color_modifier": "darkened",
		"color_amount": 0.2,
		"walkable": false,
		"resource": "wood"
	},
	"bush": {
		"color_modifier": "darkened",
		"color_amount": 0.1,
		"walkable": true
	},
	"deep_grass": {
		"color_modifier": "lightened",
		"color_amount": 0.1,
		"walkable": true
	},
	"grass": {
		"color_modifier": "none",
		"color_amount": 0,
		"walkable": true
	},
	"dirt": {
		"color_modifier": "lightened",
		"color_amount": 0.2,
		"walkable": true
	},
	
	# Swamp subterrains
	"shallow_water": {
		"color_modifier": "lightened",
		"color_amount": 0.1,
		"walkable": true,
		"is_water": true
	},
	"water": {
		"color_modifier": "darkened",
		"color_amount": 0.2,
		"walkable": false,
		"is_water": true
	},
	"mud": {
		"color_modifier": "darkened",
		"color_amount": 0.2,
		"walkable": true
	},
	"bog": {
		"color_modifier": "darkened",
		"color_amount": 0.3,
		"walkable": true
	},
	"clay": {
		"color_modifier": "lightened",
		"color_amount": 0.1,
		"walkable": true
	},
	"moss": {
		"color_modifier": "none",
		"color_amount": 0,
		"base_color": Color(0.3, 0.6, 0.3, 0.7),
		"walkable": true
	},
	
	# Mountain subterrains
	"peak": {
		"color_modifier": "darkened",
		"color_amount": 0.2,
		"walkable": false
	},
	"rocky": {
		"color_modifier": "lightened",
		"color_amount": 0.1,
		"walkable": true
	}
}

# Get terrain type based on density value
func get_terrain_type(density: float) -> String:
	for terrain_type in terrain_definitions:
		var range_values = terrain_definitions[terrain_type].density_range
		if range_values.size() == 2:
			if density >= range_values[0] and density < range_values[1]:
				return terrain_type
	return "plains"  # Default

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
	
	return true  # Default to walkable
