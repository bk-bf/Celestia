extends Node2D

var grid: Grid
var pathfinder
var debug_path = []
var start_point = null
@onready var map = get_parent()  # Reference to Map node
@onready var nav_agent = get_parent().get_node("NavigationAgent2D")

func _ready():
	# Wait until map generation is complete
	await get_tree().create_timer(0.5).timeout
	# Get grid from map's MapData
	var grid = map.map_data.terrain_grid
	# Create pathfinder with this grid
	pathfinder = Pathfinder.new(grid)
	# Enable drawing of debug lines
	set_process_input(true)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position = get_global_mouse_position()
		var grid_position = pathfinder.grid.map_to_grid(click_position)
		
		# If this is the first click, store it as start point
		if start_point == null:
			start_point = grid_position
			print("Start point set: ", grid_position)
		# If this is the second click, calculate path
		else:
			var end_point = grid_position
			print("End point set: ", end_point)
			
			# Calculate and visualize path
			debug_path = pathfinder.find_path(start_point, end_point)
			print("Path calculated with " + str(debug_path.size()) + " points")
			
			# Reset for next test
			start_point = null
			
			# Redraw to show path
			queue_redraw()

func _draw():
	# Draw visualization of path
	if debug_path.size() > 1:
		for i in range(debug_path.size() - 1):
			var start_pos = pathfinder.grid.grid_to_map(debug_path[i])
			var end_pos = pathfinder.grid.grid_to_map(debug_path[i + 1])
			draw_line(start_pos, end_pos, Color.RED, 2.0)
