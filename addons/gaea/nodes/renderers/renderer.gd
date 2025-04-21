@tool
@icon("../../assets/renderer.svg")
class_name GaeaRenderer
extends Node
## Renders the [member generator]'s result into the game.
##
## This is an abstract class. On its own, it doesn't do anything,
## but it can be extended to customize the way your generation will be rendered.


## Will render this [GaeaGenerator]'s generation results.
@export var generator: GaeaGenerator :
	set(value):
		if is_instance_valid(generator):
			if generator.generation_finished.is_connected(_render):
				generator.generation_finished.disconnect(_render)
			if generator.area_erased.is_connected(_on_area_erased):
				generator.area_erased.disconnect(_on_area_erased)
			if generator.reset_requested.is_connected(_reset):
				generator.reset_requested.disconnect(_reset)
		generator = value
		_connect_signals()



func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	if not is_instance_valid(generator):
		return

	if not generator.generation_finished.is_connected(_render):
		generator.generation_finished.connect(_render)
	if not generator.area_erased.is_connected(_on_area_erased):
		generator.area_erased.connect(_on_area_erased)
	if not generator.reset_requested.is_connected(_reset):
		generator.reset_requested.connect(_reset)


## Should be overriden with custom behavior for rendering the [param grid].
@warning_ignore("unused_parameter")
func _render(grid: GaeaGrid) -> void:
	pass


## Should be overriden with custom behavior for erasing the rendered [param area].
@warning_ignore("unused_parameter")
func _on_area_erased(area: AABB) -> void:
	pass


## Should be overriden with custom behavior to clear/_reset the previously-rendered generation.
## Should return the _render to a 'default' state,
func _reset() -> void:
	pass


## Public version of [method _render].
func render_custom(grid: GaeaGrid) -> void:
	_render(grid)
