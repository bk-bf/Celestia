class_name HUD
extends CanvasLayer

# References to UI elements (already created in the scene)
@onready var bottom_menu_bar = $Control/BottomMenuBar
@onready var pawn_menu_bar = $Control/PawnMenuBar
@onready var pawn_info_panel = $Control/PawnInfoPanel

# Button references for bottom menu (already created in the scene)
@onready var colony_button = $Control/BottomMenuBar/MenuContainer/ColonyButton
@onready var production_button = $Control/BottomMenuBar/MenuContainer/ProductionButton
@onready var planning_button = $Control/BottomMenuBar/MenuContainer/PlanningButton
@onready var research_button = $Control/BottomMenuBar/MenuContainer/ReasearchButton
@onready var world_button = $Control/BottomMenuBar/MenuContainer/WorldButton

# Button references for pawn menu (already created in the scene)
@onready var info_button = $Control/PawnMenuBar/MenuContainer/InfoButton
@onready var equip_button = $Control/PawnMenuBar/MenuContainer/EquipmentButton
@onready var needs_button = $Control/PawnMenuBar/MenuContainer/NeedsButton
@onready var health_button = $Control/PawnMenuBar/MenuContainer/HealthButton
@onready var log_button = $Control/PawnMenuBar/MenuContainer/LogButton
@onready var social_button = $Control/PawnMenuBar/MenuContainer/SocialButton

# References to game systems
var pawn_manager = null
var input_handler = null
var database_manager = null

# Current selected pawn
var selected_pawn_id = -1
var current_pawn_panel = ""

var update_timer = 0
var update_interval = 1.0 # Update every second

# Signal for log updates
signal log_entry_added(message, type)

func _process(delta):
	# Periodic update for the pawn info panel
	if pawn_info_panel.visible and selected_pawn_id != -1:
		update_timer += delta
		if update_timer >= update_interval:
			update_timer = 0
			update_pawn_info(selected_pawn_id)

func _ready():
	# Get references to game systems
	await get_tree().create_timer(0.5).timeout
	database_manager = get_node("/root/DatabaseManager")
	
	if get_node_or_null("/root/Game/Main/PawnManager"):
		pawn_manager = get_node("/root/Game/Main/PawnManager")
	
	if get_node_or_null("/root/Game/Main/InputHandler"):
		input_handler = get_node("/root/Game/Main/InputHandler")
		if !input_handler.is_connected("pawn_selected", _on_pawn_selected):
			input_handler.connect("pawn_selected", _on_pawn_selected)

	# button click debug
	print("HUD script loaded successfully")
	print("Info button reference:", info_button)

	# Connect bottom menu button signals
	colony_button.connect("pressed", _on_colony_button_pressed)
	production_button.connect("pressed", _on_production_button_pressed)
	planning_button.connect("pressed", _on_planning_button_pressed)
	research_button.connect("pressed", _on_research_button_pressed)
	world_button.connect("pressed", _on_world_button_pressed)
	
	# Connect pawn menu button signals
	info_button.pressed.connect(_on_info_button_pressed)
	equip_button.connect("pressed", _on_equip_button_pressed)
	needs_button.connect("pressed", _on_needs_button_pressed)
	health_button.connect("pressed", _on_health_button_pressed)
	log_button.connect("pressed", _on_log_button_pressed)
	social_button.connect("pressed", _on_social_button_pressed)
	
	# Connect to our own signal for adding log entries
	self.connect("log_entry_added", _add_log_entry)
	
	# Initially hide panels
	pawn_menu_bar.visible = false
	pawn_info_panel.visible = false

	if pawn_manager:
		for pawn in pawn_manager.get_all_pawns():
			if pawn.current_job:
				_connect_job_signals(pawn.current_job)

# Function to connect job signals
func _connect_job_signals(job):
	if job and !job.is_connected("job_completed", _on_job_completed):
		job.connect("job_completed", _on_job_completed)
		job.connect("job_updated", _on_job_updated)

func _add_log_entry(message, type = "info"):
	var entry = Label.new()
	entry.text = message
	
	# Style based on message type
	match type:
		"warning":
			entry.modulate = Color(1, 0.7, 0)
		"error":
			entry.modulate = Color(1, 0.3, 0.3)
		"success":
			entry.modulate = Color(0.3, 1, 0.3)
		_:
			entry.modulate = Color(0.9, 0.9, 0.9)
	
# Bottom menu button handlers
func _on_colony_button_pressed():
	print("Colony button pressed")

func _on_production_button_pressed():
	print("Production button pressed")

func _on_planning_button_pressed():
	print("Planning button pressed")

func _on_research_button_pressed():
	print("Research button pressed")

func _on_world_button_pressed():
	print("World button pressed")

# Pawn menu button handlers
func _on_info_button_pressed():
	# Set the info panel as explicitly activated
	info_panel_active = true
	pawn_info_panel.visible = true
	update_pawn_info(selected_pawn_id)
	
func _on_equip_button_pressed():
	# Hide the info panel when other buttons are pressed
	pawn_info_panel.visible = false
	print("Equipment button pressed")

func _on_needs_button_pressed():
	# Hide the info panel when other buttons are pressed
	pawn_info_panel.visible = false
	print("Needs button pressed")

func _on_health_button_pressed():
	# Hide the info panel when other buttons are pressed
	pawn_info_panel.visible = false
	print("Health button pressed")

func _on_log_button_pressed():
	# Hide the info panel when other buttons are pressed
	pawn_info_panel.visible = false
	print("Log button pressed")

func _on_social_button_pressed():
	# Hide the info panel when other buttons are pressed
	pawn_info_panel.visible = false
	print("Social button pressed")

var info_panel_active = false

# Pawn selection handling
func _on_pawn_selected(pawn_id):
	selected_pawn_id = pawn_id
	
	if pawn_id == -1:
		# No pawn selected, hide the pawn menu bar and info panel
		pawn_menu_bar.visible = false
		pawn_info_panel.visible = false
		# Reset the info panel state when deselecting a pawn
		info_panel_active = false
	else:
		# Pawn selected, show the pawn menu bar
		pawn_menu_bar.visible = true
		
		# Only show the info panel if it was explicitly activated
		if info_panel_active:
			pawn_info_panel.visible = true
			update_pawn_info(pawn_id)
		else:
			# Make sure the panel is hidden if not explicitly shown
			pawn_info_panel.visible = false
		
		# Add log entry about selection
		var pawn = pawn_manager.get_pawn(pawn_id)
		if pawn:
			emit_signal("log_entry_added", "Selected " + pawn.pawn_name, "info")

func update_pawn_info(pawn_id):
	# Get the content container
	var content_container = pawn_info_panel.get_node("ContentContainer")
	
	# Clear only the content container
	for child in content_container.get_children():
		child.queue_free()
	
	var pawn = pawn_manager.get_pawn(pawn_id)
	if not pawn:
		return
	
	# Create a VBoxContainer to organize content vertically
	var container = VBoxContainer.new()
	container.name = "InfoContainer"
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Add a styled header
	var header = Label.new()
	header.text = pawn.pawn_name
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 18)
	container.add_child(header)
	
	# Add a separator
	var separator = HSeparator.new()
	container.add_child(separator)
	
	# Add basic info in a grid
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 5)
	
	# Add attributes with proper styling
	add_attribute_row(grid, "Gender:", pawn.pawn_gender)
	add_attribute_row(grid, "Strength:", str(pawn.strength))
	add_attribute_row(grid, "Dexterity:", str(pawn.dexterity))
	add_attribute_row(grid, "Intelligence:", str(pawn.intelligence))
	
	container.add_child(grid)
	
	# Add job info with proper styling
	var job_header = Label.new()
	job_header.text = "Current Activity"
	job_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	job_header.add_theme_font_size_override("font_size", 14)
	container.add_child(job_header)
	
	var job_info = Label.new()
	job_info.name = "JobInfoLabel" # Give it a name so we can find it later
	if pawn.current_job:
		# Connect to job signals if not already connected
		if !pawn.current_job.is_connected("job_updated", _on_job_updated):
			pawn.current_job.connect("job_updated", _on_job_updated)
		if !pawn.current_job.is_connected("job_completed", _on_job_completed):
			pawn.current_job.connect("job_completed", _on_job_completed)
			
		# Just show the job type instead of full string
		job_info.text = pawn.current_job.job_type.capitalize()
	else:
		job_info.text = "Idle"
	
	job_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	job_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(job_info)
	
	# Add the container to the ContentContainer
	content_container.add_child(container)


# Signal handlers
func _on_job_completed(pawn_id, job_type, job_details):
	# Only update if this is the currently selected pawn and info panel is visible
	if pawn_id == selected_pawn_id and pawn_info_panel.visible:
		# Update the entire panel since the pawn might have a new job
		update_pawn_info(pawn_id)

func _on_job_updated(pawn_id, job_type, job_details):
	# Only update if this is the currently selected pawn and info panel is visible
	if pawn_id == selected_pawn_id and pawn_info_panel.visible:
		# Just update the job info label instead of rebuilding the entire panel
		var content_container = pawn_info_panel.get_node("ContentContainer")
		var info_container = content_container.get_node("InfoContainer")
		if info_container:
			var job_info = info_container.get_node("JobInfoLabel")
			if job_info:
				job_info.text = job_type.capitalize()

# Helper function to add attribute rows
func add_attribute_row(grid, label_text, value_text):
	var label = Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	var value = Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	grid.add_child(label)
	grid.add_child(value)


# Public methods for other scripts to use
func add_log_message(message, type = "info"):
	emit_signal("log_entry_added", message, type)

func show_pawn_info(pawn_id):
	_on_pawn_selected(pawn_id)

func hide_pawn_info():
	_on_pawn_selected(-1)

# Helper functions
func is_point_in_pawn_menu_bar(point):
	if pawn_menu_bar and pawn_menu_bar.visible:
		var rect = pawn_menu_bar.get_global_rect()
		return rect.has_point(point)
	return false

func is_point_in_pawn_info_panel(point):
	if pawn_info_panel and pawn_info_panel.visible:
		var rect = pawn_info_panel.get_global_rect()
		return rect.has_point(point)
	return false


func is_point_in_ui(point):
	if pawn_menu_bar and pawn_menu_bar.visible and pawn_menu_bar.get_global_rect().has_point(point):
		return true
	if pawn_info_panel and pawn_info_panel.visible and pawn_info_panel.get_global_rect().has_point(point):
		return true
	return false
