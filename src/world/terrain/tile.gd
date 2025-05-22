## Tile class representing a single cell in the game world grid.
## Stores terrain properties, resources, and pathfinding data.
##
## Properties:
## - terrain_type: The primary terrain type (forest, mountain, etc.)
## - terrain_subtype: Specific variation of the terrain (tree, rocky, etc.)
## - density: Terrain elevation/density value (0-1)
## - resources: Dictionary of resources present on this tile
##
## Methods:
## - is_water: Checks if tile is a water tile
## - has_resource: Checks if tile has resources
## - harvest_resource: Removes resources when harvested

class_name Tile
extends Resource

#
# Terrain Properties
#
@export var terrain_type: String = ""
@export var terrain_subtype: String = ""
@export var density: float = 0.5 # 0-1 range, 0.5 is default ground level
@export var moisture: float = 0.5
@export var temperature: float = 0.5
@export var movement_cost: float = 1.0 # Default normal movement speed
var _is_water: bool = false

#
# Pathfinding Properties
#
var g_cost: float = INF # Cost from start to this tile
var h_cost: float = 0 # Estimated cost from this tile to goal
var f_cost: float = INF # Total cost (g_cost + h_cost)
var parent: Tile = null # Previous tile in the optimal path

#
# Resource Properties
#
@export var resources: Dictionary = {} # Format: {resource_id: amount}
@export var fertility: float = 0.5

#
# Positional Data
#
@export var x: int = 0
@export var y: int = 0

#
# Gameplay Properties
#
@export var walkable: bool = true
@export var territory_owner: String = "" # For monster territory system
@export var magic_influence: Dictionary = {} # For elemental magic system

#
# Initialization
#

# Constructor with default values
func _init(coords: Vector2i = Vector2i(0, 0), den: float = 0.5, terrain: String = "plains") -> void:
    x = coords.x
    y = coords.y
    density = den
    terrain_type = terrain

#
# Coordinate Methods
#

# Get the grid coordinates of this tile
func get_coordinates() -> Vector2i:
    return Vector2i(x, y)

#
# Terrain Methods
#

# Returns true if the tile is a water tile
func is_water() -> bool:
    return _is_water or density < 0.3 or terrain_type == "ocean" or terrain_type == "lake" or terrain_type == "river"

# Sets the water state of this tile
func set_water(is_water_tile: bool) -> void:
    _is_water = is_water_tile

#
# Resource Methods
#

# Checks if the tile has a specific resource or any resources
func has_resource(resource_id = null) -> bool:
    if not "resources" in self or self.resources.size() == 0:
        return false

    if resource_id == null:
        return self.resources.size() > 0

    return resource_id in self.resources and self.resources[resource_id] > 0

# Harvests a resource from this tile and returns the amount harvested
func harvest_resource(resource_id: String, amount: int = 1) -> int:
    if has_resource(resource_id):
        var actual_amount = min(amount, self.resources[resource_id])
        self.resources[resource_id] -= actual_amount

        if self.resources[resource_id] <= 0:
            self.resources.erase(resource_id)

        return actual_amount
    return 0

# Adds a resource to this tile
func add_resource(resource_id: String, amount: int = 1) -> void:
    if resource_id.is_empty() or amount <= 0:
        return

    if not resource_id in self.resources:
        self.resources[resource_id] = 0

    self.resources[resource_id] += amount

#
# Territory Methods
#

# Checks if this tile belongs to a monster territory
func has_territory() -> bool:
    return not territory_owner.is_empty()

# Sets the territory owner for this tile
func set_territory(owner_id: String) -> void:
    territory_owner = owner_id

#
# Pathfinding Methods
#

# Resets pathfinding values for a new search
func reset_pathfinding() -> void:
    g_cost = INF
    h_cost = 0
    f_cost = INF
    parent = null

# Calculates the f_cost for pathfinding
func calculate_f_cost() -> void:
    f_cost = g_cost + h_cost
