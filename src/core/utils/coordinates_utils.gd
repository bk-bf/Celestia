class_name CoordinatesUtils
extends Object

# Get all coordinates in a circle around center
static func get_circle_coordinates(center: Vector2i, radius: int) -> Array:
	var result = []
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var coords = Vector2i(x, y)
			if center.distance_to(coords) <= radius:
				result.append(coords)
	return result

# Get coordinates in a line between start and end (Bresenham's line algorithm)
static func get_line_coordinates(start: Vector2i, end: Vector2i) -> Array:
	var result = []
	
	var x0 = start.x
	var y0 = start.y
	var x1 = end.x
	var y1 = end.y
	
	var dx = abs(x1 - x0)
	var dy = - abs(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx + dy
	
	while true:
		result.append(Vector2i(x0, y0))
		if x0 == x1 and y0 == y1:
			break
		var e2 = 2 * err
		if e2 >= dy:
			if x0 == x1:
				break
			err += dy
			x0 += sx
		if e2 <= dx:
			if y0 == y1:
				break
			err += dx
			y0 += sy
	
	return result
	
# Convert grid coords to isometric display coords
static func grid_to_isometric(grid_coords: Vector2i) -> Vector2:
	var iso_x = (grid_coords.x - grid_coords.y)
	var iso_y = (grid_coords.x + grid_coords.y) / 2
	return Vector2(iso_x, iso_y)

# Convert isometric display coords to grid coords
static func isometric_to_grid(iso_coords: Vector2) -> Vector2i:
	var grid_x = (iso_coords.x + 2 * iso_coords.y) / 2
	var grid_y = (-iso_coords.x + 2 * iso_coords.y) / 2
	return Vector2i(round(grid_x), round(grid_y))
