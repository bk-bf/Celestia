## TileMapConverter class responsible for converting MapData to visual TileMap representation.
## Handles conversion of logical terrain data to visual tilemap graphics.
##
## Properties:
## - ground_layer: TileMap for base terrain visualization
## - object_layer: TileMap for objects and features
## - map_data: The MapData to convert and visualize
##
## Methods:
## - update_tilemap_from_world_data: Updates tilemaps based on map data

class_name TileMapConverter
extends Node

# References to your TileMap layers
@export var ground_layer: TileMap
@export var object_layer: TileMap

# The MapData to visualize
@export var map_data: MapData

# Constants for tile coordinates and thresholds
const GROUND_SOURCE_ID: int = 0
const OBJECT_SOURCE_ID: int = 1
const MOUNTAIN_DENSITY_THRESHOLD: float = 0.8
const SHALLOW_WATER_DENSITY_THRESHOLD: float = 0.3

# Base icon coordinates for resources
const RESOURCE_BASE_COORDS: Vector2i = Vector2i(6, 0)

func _ready() -> void:
    # No initialization needed - we'll handle resources dynamically
    pass

# Convert MapData to TileMap visualization
func update_tilemap_from_world_data() -> void:
    if !map_data or !ground_layer or !object_layer:
        push_error("Missing required references")
        return

    # Clear layers
    ground_layer.clear()
    object_layer.clear()

    # Set cell size to match
    var cell_size = ground_layer.tile_set.tile_size

    # Update your Grid's cell size if needed
    map_data.terrain_grid.cell_size = Vector2(cell_size)

    # Draw all tiles
    for y in range(map_data.get_height()):
        for x in range(map_data.get_width()):
            var coords = Vector2i(x, y)
            var tile = map_data.get_tile(coords)
            var atlas_coords = get_atlas_coords_for_tile(tile)

            # Place ground tile
            ground_layer.set_cell(0, coords, GROUND_SOURCE_ID, atlas_coords)

            # Place objects and resources
            place_objects_and_resources(coords, tile)

# Place objects and resources on a tile
func place_objects_and_resources(coords: Vector2i, tile: Tile) -> void:
    # Place trees in dense forest areas
    if tile.terrain_type == "forest" and tile.density > 0.7:
        var tree_coords = Vector2i(0, 0) # Your tree tile coordinates
        object_layer.set_cell(0, coords, OBJECT_SOURCE_ID, tree_coords)
    # Place resources
    elif tile.has_resource():
        place_resource_tile(coords, tile)

# Place resource indicator on a tile
func place_resource_tile(coords: Vector2i, tile: Tile) -> void:
    if !tile.has_resource():
        return

    # Get resource database instance for lookup
    var resource_db = DatabaseManager.resource_database

    # Get the primary resource type
    var resource_type = get_primary_resource_type(tile)

    # Set a base resource icon - we'll use the same icon for all resources
    # This avoids hardcoding resource types completely
    object_layer.set_cell(0, coords, OBJECT_SOURCE_ID, RESOURCE_BASE_COORDS)

    # NOTE: If you do want different icons later,
    # add a "tile_icon" field to your resource definitions in resource_database.gd

# Get the primary resource type from a tile
func get_primary_resource_type(tile: Tile) -> String:
    if !tile.has_resource() or tile.resources.size() == 0:
        return ""

    # Return the first resource type (assuming one per tile)
    return tile.resources.keys()[0]

# Helper to determine which tile to use based on tile properties
func get_atlas_coords_for_tile(tile: Tile) -> Vector2i:
    # This is where you'd determine which visual tile to use based on the tile's properties
    if tile.is_water():
        return Vector2i(0, 0) # Water tile atlas coords
    elif tile.density > MOUNTAIN_DENSITY_THRESHOLD:
        return Vector2i(1, 0) # Mountain/rock tile
    elif tile.density < SHALLOW_WATER_DENSITY_THRESHOLD:
        return Vector2i(2, 0) # Sand/shallow water
    else:
        return Vector2i(3, 0) # Grass/normal ground

# Refreshes a specific tile's visualization
func refresh_tile(coords: Vector2i) -> void:
    var tile = map_data.get_tile(coords)
    if tile:
        var atlas_coords = get_atlas_coords_for_tile(tile)
        ground_layer.set_cell(0, coords, GROUND_SOURCE_ID, atlas_coords)

        # Clear and update object layer for this tile
        object_layer.set_cell(0, coords, -1) # Clear cell
        place_objects_and_resources(coords, tile)