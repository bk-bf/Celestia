@tool
extends GaeaNodeResource
class_name GaeaNodeFloorWalker
## Generates a floor by using [b]walkers[/b], which move around and
## set cells where they walk to [code]1.0[/code], while changing direction and/or spawning new walkers.
##
## The algorithm starts from the [param starting_point]. It spawns a [GaeaNodeWalker] with that
## position, and that walker starts moving randomly. Depending on the chances configured,
## every 'turn' it has a chance to spawn a new walker, to change its direction, to be destroyed,
## to place cells in a bigger area, etc. All cells where it walks will be set to a value of
## [code]1.0[/code].[br]
## When a size of [param max_cells] is reached, the generation will stop.[br][br]
## This is how [url=https://nuclearthrone.com]Nuclear Throne[/url] does its generation,
## for example, as seen [url=https://web.archive.org/web/20151009004931/https://www.vlambeer.com/2013/04/02/random-level-generation-in-wasteland-kings/]here[/url].


## Whether the walkers should walk along the [code]X[/code] and [code]Y[/code] axis
## or the [code]X[/code] and [code]Z[/code] axis.
@export var second_axis: Axis = Axis.Y


## Walker as used in [GaeaNodeFloorWalker].
class Walker:
	var dir: Vector3 ## Current direction, should be in 90-degrees angles.
	var pos: Vector3 ## Current position, should be rounded.


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var _starting_position: Vector3 = _get_arg(&"starting_position", area, generator_data)
	_starting_position = _starting_position.round()

	var rotation_weights: Dictionary = {
		PI / 2.0: _get_arg(&"rotate_90_weight", area, generator_data),
		-PI / 2.0: _get_arg(&"rotate_-90_weight", area, generator_data),
		PI: _get_arg(&"rotate_180_weight", area, generator_data)
	}
	var direction_change_chance: float = float(_get_arg(&"direction_change_chance", area, generator_data)) / 100.0
	var new_walker_chance: float = float(_get_arg(&"new_walker_chance", area, generator_data)) / 100.0
	var destroy_walker_chance: float = float(_get_arg(&"destroy_walker_chance", area, generator_data)) / 100.0
	var bigger_room_chance: float = float(_get_arg(&"bigger_room_chance", area, generator_data)) / 100.0
	var bigger_room_size_range: Dictionary = _get_arg(&"bigger_room_size_range", area, generator_data)

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.set_seed(generator_data.generator.seed + salt)
	seed(generator_data.generator.seed + salt)
	var max_cells: int = _get_arg(&"max_cells", area, generator_data)
	max_cells = mini(
		max_cells,
		roundi(area.size.x) * (roundi(area.size.y) if second_axis == Axis.Y else roundi(area.size.z))
	)

	var _walkers: Array[Walker]
	var _walked_cells: Array[Vector3i]

	var iterations: int = 0

	_add_walker(_starting_position, _walkers)

	while iterations < 10000 and _walked_cells.size() < max_cells:
		for walker in _walkers:

			if rng.randf() <= destroy_walker_chance and _walkers.size() > 1:
				_walkers.erase(walker)
				continue

			if rng.randf() <= new_walker_chance:
				_add_walker(walker.pos, _walkers)

			if rng.randf() <= direction_change_chance:
				walker.dir = walker.dir.rotated(
					Vector3(0, 0, 1) if second_axis == Axis.Y else Vector3(0, 1, 0),
					rotation_weights.keys()[rng.rand_weighted(rotation_weights.values())]
					).round()

			if rng.randf() <= bigger_room_chance:
				var size: int = rng.randi_range(bigger_room_size_range.min, bigger_room_size_range.max)
				for cell in _get_square_room(walker.pos, Vector3(size, size if second_axis == Axis.Y else 1, size if second_axis == Axis.Z else 1)):
					cell = cell.clamp(area.position, area.end - Vector3.ONE)
					if not _walked_cells.has(Vector3i(cell)):
						_walked_cells.append(Vector3i(cell))

			walker.pos += walker.dir
			walker.pos = walker.pos.clamp(area.position, area.end - Vector3.ONE )

			if not _walked_cells.has(Vector3i(walker.pos)):
				_walked_cells.append(Vector3i(walker.pos))

			if _walked_cells.size() >= max_cells:
				break

		iterations += 1

	var grid: Dictionary[Vector3i, float]
	for cell in _walked_cells:
		grid[cell] = 1.0

	return output_port.return_value(grid)


func _add_walker(pos: Vector3, array: Array[Walker]) -> void:
	var walker: Walker = Walker.new()
	walker.pos = pos
	walker.dir = [
		Vector3.LEFT,
		Vector3.RIGHT,
		Vector3.DOWN if second_axis == Axis.Y else Vector3.FORWARD,
		Vector3.UP if second_axis == Axis.Y else Vector3.BACK].pick_random()
	array.append(walker)


func _get_square_room(starting_pos: Vector3, size: Vector3) -> PackedVector3Array:
	var tiles: PackedVector3Array = []
	var x_offset = floor(size.x / 2)
	var y_offset = floor(size.y / 2)
	var z_offset = floor(size.z / 2)
	for x in size.x:
		for y in size.y:
			for z in size.z:
				var coords = starting_pos + Vector3(x - x_offset, y - y_offset, z - z_offset)
				tiles.append(coords)
	return tiles
