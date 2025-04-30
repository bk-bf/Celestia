extends Camera2D

# Camera movement speed
@export var pan_speed: float = 500.0

# Zoom properties
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_speed: float = 0.1
@export var zoom_margin: float = 0.1

# Smoothing properties
@export var smoothing_enabled: bool = true
@export var smoothing_speed: float = 10.0

var target_zoom = Vector2(1, 1)
var target_position = Vector2.ZERO
var is_dragging = false
var drag_start_position = Vector2.ZERO

func _ready():
	target_position = global_position
	target_zoom = zoom

func _process(delta):
	# Handle smooth movement
	if smoothing_enabled:
		global_position = global_position.lerp(target_position, smoothing_speed * delta)
		zoom = zoom.lerp(target_zoom, smoothing_speed * delta)
	else:
		global_position = target_position
		zoom = target_zoom

func _input(event):
	# Handle mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and Input.is_action_pressed("camera_zoom_in"):
			zoom_camera(zoom_speed, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and Input.is_action_pressed("camera_zoom_out"):
			zoom_camera(-zoom_speed, event.position)

func _physics_process(delta):
	# Handle keyboard panning
	var input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("camera_pan_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("camera_pan_down"):
		input_dir.y += 1
	if Input.is_action_pressed("camera_pan_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("camera_pan_right"):
		input_dir.x += 1
	
	# Normalize diagonal movement
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()
	
	# Adjust speed based on zoom level (faster when zoomed out)
	var adjusted_speed = pan_speed * (1.0 / zoom.x)
	target_position += input_dir * adjusted_speed * delta

func zoom_camera(zoom_factor, mouse_position):
	# Get mouse position in viewport
	var viewport_size = get_viewport_rect().size
	
	# Get direction from the center to the mouse position
	var mouse_direction = (mouse_position - viewport_size / 2).normalized()
	
	# Calculate new zoom
	var new_zoom = clamp(target_zoom.x + zoom_factor, min_zoom, max_zoom)
	
	# Only apply zoom if it's within the limits
	if (new_zoom > target_zoom.x && target_zoom.x < max_zoom) || (new_zoom < target_zoom.x && target_zoom.x > min_zoom):
		# Offset to maintain position under mouse
		var zoom_offset = Vector2.ZERO
		if mouse_direction != Vector2.ZERO:
			zoom_offset = mouse_direction * zoom_margin
		
		target_zoom = Vector2(new_zoom, new_zoom)
