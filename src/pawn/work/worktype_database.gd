class_name WorkTypeDatabase
extends Resource

# Dictionary to store work type definitions
# Format: { "work_type_id": work_type_data }
var work_types = {
    "harvesting": {
        "display_name": "Harvesting",
        "description": "Cutting trees and gathering plants",
        "icon": "harvest_icon.png",
        "related_skills": ["harvesting_speed", "plant_knowledge"],
        "job_classes": ["HarvestingJob"]
    },
    "mining": {
        "display_name": "Mining",
        "description": "Extracting ore and stone",
        "icon": "mine_icon.png",
        "related_skills": ["mining_speed", "stone_knowledge"],
        "job_classes": ["MiningJob"]
    },
    "construction": {
        "display_name": "Construction",
        "description": "Building structures",
        "icon": "construct_icon.png",
        "related_skills": ["construction_speed", "building_quality"],
        "job_classes": ["ConstructionJob"]
    },
    "hauling": {
        "display_name": "Hauling",
        "description": "Moving resources",
        "icon": "haul_icon.png",
        "related_skills": ["carrying_capacity", "movement_speed"],
        "job_classes": ["HaulingJob"]
    },
    "cooking": {
        "display_name": "Cooking",
        "description": "Preparing meals",
        "icon": "cook_icon.png",
        "related_skills": ["cooking_quality", "cooking_speed"],
        "job_classes": ["CookingJob"]
    }
}

# Get a work type by ID
func get_work_type(work_type_id: String) -> Dictionary:
    if work_types.has(work_type_id):
        return work_types[work_type_id].duplicate()
    return {}

# Get all work types
func get_all_work_types() -> Dictionary:
    return work_types.duplicate()

# Get work types sorted by display name
func get_sorted_work_types() -> Array:
    var sorted_types = []
    for work_id in work_types.keys():
        sorted_types.append({
            "id": work_id,
            "display_name": work_types[work_id].display_name
        })
    
    # Sort by display name
    sorted_types.sort_custom(func(a, b): return a.display_name < b.display_name)
    
    return sorted_types

# Check if a job class belongs to a work type
func get_work_type_for_job_class(job_class: String) -> String:
    for work_id in work_types.keys():
        if job_class in work_types[work_id].job_classes:
            return work_id
    return ""

# Get related skills for a work type
func get_related_skills(work_type_id: String) -> Array:
    if work_types.has(work_type_id):
        return work_types[work_type_id].related_skills.duplicate()
    return []
