# core/utils/map_renderer.gd
class_name MapRenderer
extends RefCounted

var map_data: MapData
var terrain_database: TerrainDatabase
var territory_database: TerritoryDatabase
var pathfinder = null
var input_handler = null
var resource_db: ResourceDatabase
var cell_size: Vector2
var camera: Camera2D
var zoom_threshold: float = 0.5
var debug_path: Array = []
var map: MapRenderer
var drawing_node: CanvasItem

# TileMapLayer
var terrain_tilemap: TileMapLayer = null
var subterrain_tilemap: TileMapLayer = null


# Configuration flags
var show_terrain_tiles: bool = false
var show_grid_lines: bool = false
var show_coordinate_numbers: bool = true
var show_density_values: bool = false
var show_movement_costs: bool = false
var show_terrain_letters: bool = false
var show_territory_markers: bool = false
var show_resources: bool = false
var show_draw_designations: bool = true

# Tracker
var dirty_tiles = {}

func _init(
	map_data_ref,
	terrain_db_ref,
	territory_db_ref,
	pathfinder_ref,
	resource_db_ref,
	cell_size_ref,
	camera_ref,
	input_handler_ref = null
):
	map_data = map_data_ref
	terrain_database = terrain_db_ref
	territory_database = territory_db_ref
	pathfinder = pathfinder_ref
	resource_db = resource_db_ref
	cell_size = cell_size_ref
	camera = camera_ref
	input_handler = input_handler_ref
	var dirty_tiles = {}


func initialize(map_data_ref, terrain_map, subterrain_map):
	map_data = map_data_ref
	terrain_tilemap = terrain_map
	subterrain_tilemap = subterrain_map
	
	# Connect to the signal
	#var connection_result = map_data.connect("tile_resource_changed", _on_tile_resource_changed)
	#print("Signal connection result:", connection_result)


#func _on_tile_resource_changed(position):
#	print("Received tile_resource_changed signal for position: ", position)
#	var tile = map_data.get_tile(position)
#	
	# Update the subterrain tile based on resource state
#	if tile.terrain_subtype != "":
#		var subterrain_id = terrain_database.get_subterrain_tile_id(tile.terrain_subtype)
		
		# Make sure position is a Vector2i
#		var tile_coords = Vector2i(position.x, position.y)
		
		# Properly set the cell with correct parameter types
#		subterrain_tilemap.set_cell(tile_coords, 0, subterrain_id, 0)
#

# Main render function that calls all the specific drawing functionsddda
func render(canvas_item: CanvasItem):
	if !map_data:
		return
	
	if show_grid_lines:
		draw_grid_lines(canvas_item)
	
	if show_territory_markers:
		draw_territory_markers(canvas_item)

	if draw_pathfinder:
		draw_pathfinder(canvas_item)
	
	if show_coordinate_numbers:
		draw_coordinate_numbers(canvas_item)
	
	if show_density_values:
		draw_density_values(canvas_item)
	
	if show_movement_costs:
		draw_movement_costs(canvas_item)
	
	if show_terrain_letters:
		draw_terrain_letters(canvas_item)
	
	if show_draw_designations:
		draw_designations(canvas_item)


# Draw the grid lines
func draw_grid_lines(canvas_item: CanvasItem):
	var width = map_data.get_width() * cell_size.x
	var height = map_data.get_height() * cell_size.y
	
	# Draw vertical lines
	for x in range(map_data.get_width() + 1):
		var start = Vector2(x * cell_size.x, 0)
		var end = Vector2(x * cell_size.x, height)
		canvas_item.draw_line(start, end, Color.DARK_GRAY, 1.0)
		
	# Draw horizontal lines
	for y in range(map_data.get_height() + 1):
		var start = Vector2(0, y * cell_size.y)
		var end = Vector2(width, y * cell_size.y)
		canvas_item.draw_line(start, end, Color.DARK_GRAY, 1.0)

# Draw territory markers
func draw_territory_markers(canvas_item: CanvasItem):
	var custom_font = preload("res://assets/fonts/Roboto_Condensed/RobotoCondensed-Bold.ttf")
	var font_size_territory = 10
	
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var grid_coords = Vector2i(x, y)
			var tile = map_data.get_tile(grid_coords)
			
			if tile.territory_owner != "":
				var territory_letter = tile.territory_owner.substr(0, 1).to_upper()
				var text_size = custom_font.get_string_size(territory_letter, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_territory)
				
				var center = Vector2(
					x * cell_size.x + cell_size.x / 2,
					y * cell_size.y + cell_size.y / 2
				)
				
				# Calculate position to center the letter
				var text_pos = Vector2(
					center.x - text_size.x / 2,
					center.y + text_size.y / 2
				)
				
				# Get color from territory_database on territory_owner
				var letter_color = Color(0.9, 0.2, 0.2, 0.9) # Default red fallback
				if territory_database and tile.territory_owner in territory_database.territory_definitions:
					var monster_data = territory_database.territory_definitions[tile.territory_owner]
					if "color" in monster_data:
						letter_color = monster_data.color
				
				# Draw the letter
				canvas_item.draw_string(custom_font, text_pos, territory_letter, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_territory, letter_color)

func set_debug_path(path: Array):
	debug_path = path

func draw_pathfinder(canvas_item: CanvasItem):
	if debug_path.size() > 1:
		for i in range(debug_path.size() - 1):
			var start_pos = map_data.grid_to_map(debug_path[i])
			var end_pos = map_data.grid_to_map(debug_path[i + 1])
			canvas_item.draw_line(start_pos, end_pos, Color.RED, 1.0)

# Helper method to draw resources for a single tile
func _draw_tile_resources(canvas_item: CanvasItem, grid_coords: Vector2i):
	var tile = map_data.get_tile(grid_coords)
	
	# For dirty tiles with no resources, we need to clear any previous resource visuals
	# by redrawing the terrain
	if not "resources" in tile or tile.resources.size() == 0:
		# Get the tile's terrain color to redraw the background
		var base_color = Color.WHITE
		if tile.terrain_type in terrain_database.terrain_definitions:
			base_color = terrain_database.terrain_definitions[tile.terrain_type].base_color
		
		# Apply subterrain modification if applicable
		var color = base_color
		if tile.terrain_subtype != "":
			color = terrain_database.get_modified_color(base_color, tile.terrain_subtype)
		
		# Redraw the tile background to clear any resource visuals
		var rect = Rect2(
			grid_coords.x * cell_size.x,
			grid_coords.y * cell_size.y,
			cell_size.x,
			cell_size.y
		)
		canvas_item.draw_rect(rect, color)
		return
	
	# Draw resources if present
	for resource_id in tile.resources.keys():
		# Skip if resource amount is 0 or negative
		if tile.resources[resource_id] <= 0:
			continue
			
		var resource_data = resource_db.get_resource(resource_id)
		if resource_data:
			var resource_color = resource_data.color
			
			# Draw resource indicator
			var pixel_pos = Vector2(
				grid_coords.x * cell_size.x + cell_size.x / 2,
				grid_coords.y * cell_size.y + cell_size.y / 2
			)
			canvas_item.draw_circle(pixel_pos, cell_size.x * 0.25, resource_color)
			
			# For larger resource amounts, add visual indicator
			if tile.resources[resource_id] > 1:
				var custom_font = preload("res://assets/fonts/Roboto_Condensed/RobotoCondensed-Bold.ttf")
				var font_size = cell_size.x * 0.4
				canvas_item.draw_string(
							custom_font,
							pixel_pos + Vector2(-font_size * 0.25, font_size * 0.3),
							str(tile.resources[resource_id]),
							HORIZONTAL_ALIGNMENT_CENTER,
							-1,
							font_size,
							resource_color.darkened(0.3),
							)

# Draw coordinate numbers
func draw_coordinate_numbers(canvas_item: CanvasItem):
	var custom_font = preload("res://assets/fonts/Roboto_Condensed/RobotoCondensed-Bold.ttf")
	var font_size_coordinates = 3
	
	if camera.zoom.x > zoom_threshold:
		return
	
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var label = "(%d,%d)" % [x, y]
			var text_size = custom_font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_coordinates)
			var text_pos = Vector2(
				x * cell_size.x + (cell_size.x - text_size.x) / 2,
				y * cell_size.y + (cell_size.y + text_size.y) / 2
			)
			canvas_item.draw_string(custom_font, text_pos, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_coordinates)

# Draw density values
func draw_density_values(canvas_item: CanvasItem):
	var custom_font = preload("res://assets/fonts/Roboto_Condensed/RobotoCondensed-Bold.ttf")
	var font_size_density = 4
	
	if camera.zoom.x > zoom_threshold * 1.5:
		return
	
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var grid_coords = Vector2i(x, y)
			var tile = map_data.get_tile(grid_coords)
			
			var density_str = "%.1f" % tile.density # Format to 1 decimal place
			
			# Position the density in the lower-right corner of the tile
			var density_pos = Vector2(
				(x + 1) * cell_size.x - 2 - custom_font.get_string_size(density_str, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size_density).x,
				(y + 1) * cell_size.y - 2
			)
			
			# Use a contrasting color for visibility
			var density_color = Color.WHITE
			if tile.is_water():
				density_color = Color.WHITE
			elif tile.terrain_type == "mountain":
				density_color = Color.BLACK
			
			canvas_item.draw_string(custom_font, density_pos, density_str, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size_density, density_color)

# Draw movement costs or walkability indicators
func draw_movement_costs(canvas_item: CanvasItem):
	var custom_font = preload("res://assets/fonts/Roboto_Condensed/RobotoCondensed-Bold.ttf")
	var font_size_cost = 4
	
	if camera.zoom.x > zoom_threshold * 1.5:
		return
	
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var grid_coords = Vector2i(x, y)
			var tile = map_data.get_tile(grid_coords)
			
			# Calculate tile pixel positions
			var tile_x = x * cell_size.x
			var tile_y = y * cell_size.y
			
			if tile.walkable:
				# For walkable tiles, show movement cost
				var movement_cost = 1.0
				if tile.terrain_type in terrain_database.terrain_definitions:
					movement_cost = terrain_database.terrain_definitions[tile.terrain_type].get("movement_cost", 1.0)
				
				# Format as percentage
				var cost_str = str(int(movement_cost * 100)) + "%"
				
				# Position in bottom-left corner with padding
				var cost_pos = Vector2(
					tile_x + 2, # 2 pixels from left edge
					tile_y + cell_size.y - 2 # 2 pixels from bottom edge
				)
				
				# Use contrasting color for visibility
				var cost_color = Color.WHITE
				if tile.is_water():
					cost_color = Color.WHITE
				elif tile.terrain_type == "mountain":
					cost_color = Color.BLACK
				
				canvas_item.draw_string(custom_font, cost_pos, cost_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size_cost, cost_color)
			else:
				# For non-walkable tiles, draw a red X
				var red_color = Color(1.0, 0.2, 0.2, 0.9) # Bright red
				var padding = 4 # Padding from edges
				
				# Draw X lines
				var x1 = tile_x + padding
				var y1 = tile_y + padding
				var x2 = tile_x + cell_size.x - padding
				var y2 = tile_y + cell_size.y - padding
				
				# Line 1: top-left to bottom-right
				canvas_item.draw_line(Vector2(x1, y1), Vector2(x2, y2), red_color, 2.0)
				# Line 2: bottom-left to top-right
				canvas_item.draw_line(Vector2(x1, y2), Vector2(x2, y1), red_color, 2.0)

# Draw terrain and subterrain type letters
func draw_terrain_letters(canvas_item: CanvasItem):
	var custom_font = preload("res://assets/fonts/Roboto_Condensed/RobotoCondensed-Bold.ttf")
	var font_size_terrain = 4
	
	if camera.zoom.x > zoom_threshold * 1.5:
		return
	
	for y in range(map_data.get_height()):
		for x in range(map_data.get_width()):
			var grid_coords = Vector2i(x, y)
			var tile = map_data.get_tile(grid_coords)
			
			# Get first letter of terrain and subterrain
			var terrain_letter = tile.terrain_type.substr(0, 1).to_upper()
			var subterrain_letter = ""
			if tile.terrain_subtype != "":
				subterrain_letter = tile.terrain_subtype.substr(0, 1).to_upper()
			
			# Format as "T/S" or just "T" if no subterrain
			var type_label = terrain_letter
			if subterrain_letter != "":
				type_label = terrain_letter + "/" + subterrain_letter
			
			# Position in center-top of tile
			var label_pos = Vector2(
				x * cell_size.x + cell_size.x / 2 - custom_font.get_string_size(type_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_terrain).x / 2,
				y * cell_size.y + font_size_terrain + 2
			)
			
			# Choose contrasting colors based on terrain type
			var label_color = Color.WHITE
			if tile.terrain_type == "forest":
				label_color = Color.WHITE
			elif tile.is_water():
				label_color = Color.WHITE
			
			canvas_item.draw_string(custom_font, label_pos, type_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size_terrain, label_color)

# Draw designation overlays
func draw_designations(canvas_item: CanvasItem):
	var designation_manager = DatabaseManager.designation_manager
	
	for designation_type in designation_manager.designations.keys():
		for position in designation_manager.designations[designation_type].keys():
			var color = designation_manager.designation_indicators[designation_type].color
			var world_pos = map_data.grid_to_map(position)
			var tile_size = map_data.get_tile_size()
			var rect = Rect2(world_pos, tile_size)
			canvas_item.draw_rect(rect, color)
