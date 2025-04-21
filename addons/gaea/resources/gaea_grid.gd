@tool
class_name GaeaGrid
extends Resource
## Result of a Gaea generation.


## Dictionary of the format [code]{int: Dictionary}[/code] where the key is the layer index
## and the value is a grid of [GaeaMaterial]s.
var _grid: Dictionary[int, Dictionary]


## Set the layer at [param idx] to the generated [param grid].
## Sets it to an empty grid if [param resource] is disabled (see [member GaeaLayer.enabled]).
func add_layer(idx: int, grid: Dictionary, resource: GaeaLayer) -> void:
	if resource.enabled == false:
		_grid[idx] = {}
		return

	_grid[idx] = grid

## Get the grid at layer [param idx],
func get_layer(idx: int) -> Dictionary:
	return _grid.get(idx)

## Get the amount of layers the grid has.
func get_layers_count() -> int:
	return _grid.size()
