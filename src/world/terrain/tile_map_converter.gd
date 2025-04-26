
class_name TileMapConverter
extends Node

# References to your TileMap layers
@export var ground_layer: TileMap
@export var object_layer: TileMap

# The MapData to visualize
@export var map_data: MapData

# Convert MapData to TileMap visualization
func update_tilemap_from_world_data():
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
			var tile = map_data.get_tile(Vector2i(x, y))
			var atlas_coords = get_atlas_coords_for_tile(tile)
			
			# Place ground tile
			ground_layer.set_cell(0, Vector2i(x, y), 0, atlas_coords)
			
			# Place objects if needed
			if tile.biome_type == "forest" and tile.density > 0.7:
				var tree_coords = Vector2i(0, 0)  # Your tree tile coordinates
				object_layer.set_cell(0, Vector2i(x, y), 1, tree_coords)

# Helper to determine which tile to use based on tile properties
func get_atlas_coords_for_tile(tile: Tile) -> Vector2i:
	# This is where you'd determine which visual tile to use based on the tile's properties
	if tile.is_water():
		return Vector2i(0, 0)  # Water tile atlas coords
	elif tile.density > 0.8:
		return Vector2i(1, 0)  # Mountain/rock tile
	elif tile.density < 0.3:
		return Vector2i(2, 0)  # Sand/shallow water
	else:
		return Vector2i(3, 0)  # Grass/normal ground
