class_name MapDisplayConfig
extends Resource

@export var show_grid_lines: bool = false
@export var show_coordinate_numbers: bool = false
@export var show_terrain_letters: bool = false
@export var show_territory_markers: bool = true
@export var show_density_values: bool = false
@export var show_movement_costs: bool = false
@export var show_resources: bool = false

func to_dictionary() -> Dictionary:
    return {
        "show_grid_lines": show_grid_lines,
        "show_coordinate_numbers": show_coordinate_numbers,
        "show_terrain_letters": show_terrain_letters,
        "show_territory_markers": show_territory_markers,
        "show_density_values": show_density_values,
        "show_movement_costs": show_movement_costs,
        "show_resources": show_resources
    }

func from_dictionary(data: Dictionary) -> void:
    show_grid_lines = data.get("show_grid_lines", true)
    show_coordinate_numbers = data.get("show_coordinate_numbers", true)
    show_terrain_letters = data.get("show_terrain_letters", true)
    show_territory_markers = data.get("show_territory_markers", true)
    show_density_values = data.get("show_density_values", true)
    show_movement_costs = data.get("show_movement_costs", true)
    show_resources = data.get("show_resources", true)