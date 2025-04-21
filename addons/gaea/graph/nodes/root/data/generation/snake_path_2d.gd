@tool
extends GaeaNodeResource
class_name GaeaNodeSnakePath2D
## Generates a path that goes from the top of the world to the bottom,
## with each cell consisting of flags that indicate their exits (up, down, left, right).
##
## The algorithm starts from a random point in the top row of the generation area.[br]
## From there, it'll either move left, right or down, depending on the configured weights.[br]
## If it reaches a border, and tries to move outside the bounds of the generation area, it'll
## drop down.[br][br]
## Each cell has a value with flags representing the path the algorithm took. Whenever it drops down,
## the cell where it ended up will have the [param up] flag, for example, showing that the
## path is connected with an exit to the cell above (which has the [param down] flag).[br][br]
## This is how [url=https://www.spelunkyworld.com/]Spelunky[/url]
## generates its level layouts as seen [url=https://tinysubversions.com/spelunkyGen/]here[/url].


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var direction_weights: Dictionary[Vector2i, float] = {
		Vector2i.LEFT: _get_arg(&"move_left_weight", area, generator_data),
		Vector2i.RIGHT: _get_arg(&"move_right_weight", area, generator_data),
		Vector2i.DOWN: _get_arg(&"move_down_weight", area, generator_data),
	}
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var left_flag: int = _get_arg(&"left", area, generator_data)
	var right_flag: int = _get_arg(&"right", area, generator_data)
	var down_flag: int = _get_arg(&"down", area, generator_data)
	var up_flag: int = _get_arg(&"up", area, generator_data)
	var direction_to_flags: Dictionary = {
		Vector2i.LEFT: left_flag,
		Vector2i.RIGHT: right_flag,
		Vector2i.DOWN: down_flag,
		Vector2i.UP: up_flag
	}
	rng.set_seed(generator_data.generator.seed + salt)

	var path: Dictionary
	var grid: Dictionary[Vector3i, float] = {}
	var starting_cell: Vector2i = Vector2i(rng.randi_range(0, area.size.x - 1), 0)
	var last_cell: Vector2i = starting_cell
	var current_cell: Vector2i = starting_cell
	var last_direction: Vector2i = Vector2i.ZERO

	while true:
		path[current_cell] = direction_to_flags.get(-last_direction, 0)
		if path.get(last_cell, 0) & down_flag:
			path[current_cell] |= up_flag

		var direction: Vector2i
		while path.has(current_cell + direction):
			direction = direction_weights.keys()[rng.rand_weighted(direction_weights.values())]

		if (current_cell + direction).x < 0 or (current_cell + direction).x >= area.size.x:
			direction = Vector2i.DOWN

		if direction == Vector2i.DOWN and (current_cell.y + 1) >= area.size.y:
			break

		path[current_cell] |= direction_to_flags.get(direction)

		last_cell = current_cell
		last_direction = direction
		current_cell += direction

	for cell in path:
		grid[Vector3i(cell.x, cell.y, 0)] = path.get(cell)

	return output_port.return_value(grid)
