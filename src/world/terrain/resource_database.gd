class_name ResourceDatabase
extends Resource

var resources = {
    "wood": {
        "display_name": "Wood",
        "terrain_type": ["forest"],
        "terrain_subtype": ["tree"],
        "frequency": 1.0, # Higher values = more common
        "cluster_size": 3, # Average resources per cluster
        "harvest_tool": "axe",
		"skill_used": ["woodcutting"],
        "harvest_time": 5.0,
        "yield_amount": [2, 4], # Random range
        "color": Color(0.54, 0.27, 0.07)
    },
    "stone": {
        "display_name": "Stone",
        "terrain_type": ["mountain"],
        "terrain_subtype": ["rocky", "cliff", "peak"],
        "frequency": 1.0,
        "cluster_size": 4,
        "harvest_tool": ["pickaxe"],
		"skill_used": "mining",
        "harvest_time": 8.0,
        "yield_amount": [3, 6],
        "color": Color(0.7, 0.7, 0.7)
    },
    "herbs": {
        "display_name": "Herbs",
        "terrain_type": ["plains", "forest"],
        "terrain_subtype": ["flower_field", "moss", "deep_grass"],
        "frequency": 1.0,
        "cluster_size": 2,
        "harvest_tool": ["none", "knife"],
		"skill_used": "gathering",
        "harvest_time": 3.0,
        "yield_amount": [1, 3],
        "color": Color(0.2, 0.8, 0.4)
    }
}

func get_resource(resource_id):
    if resources.has(resource_id):
        return resources[resource_id]
    return null
