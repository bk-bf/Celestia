var current_path: Array = []
var pathfinder: Pathfinder

func _ready():
	pathfinder = Pathfinder.new(get_node("/root/Game/World").grid)

func move_to(target_position: Vector2):
	current_path = pathfinder.find_path(position, target_position)
	# Start following the path

func _process(delta):
	if current_path.size() > 0:
		# Move along path
		var next_point = current_path[0]
		var move_dir = (next_point - position).normalized()
		position += move_dir * speed * delta
		
		# Check if reached the next point
		if position.distance_to(next_point) < 5:
			position = next_point  # Snap to grid
			current_path.pop_front()
