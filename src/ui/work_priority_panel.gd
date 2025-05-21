class_name WorkPriorityPanel
extends Control

# References
var work_priority_manager = null
var work_type_database = null
var pawn_manager = null

# UI elements
@onready var grid_container = $ContentContainer/ScrollContainer/GridContainer
@onready var header_container = $ContentContainer/HeaderContainer

func _ready():
	# Get references
	work_priority_manager = WorkPriorityManager.get_instance()
	work_type_database = DatabaseManager.work_type_database
	pawn_manager = DatabaseManager.pawn_manager
	
	# Connect signals
	work_priority_manager.connect("priorities_changed", _on_priorities_changed)
	
	# Add spacing to grid container
	grid_container.add_theme_constant_override("h_separation", 10)
	grid_container.add_theme_constant_override("v_separation", 8)
	
	# Populate the grid
	_populate_grid()
	
	# Debug output
	print("WorkPriorityPanel initialized with ", pawn_manager.get_all_pawns().size(), " pawns")

func _populate_grid():
	# Clear existing children
	for child in grid_container.get_children():
		child.queue_free()
	
	# Clear header container
	for child in header_container.get_children():
		child.queue_free()
	
	# Get work types and pawns
	var work_types = work_type_database.get_sorted_work_types()
	var pawns = pawn_manager.get_all_pawns()
	
	# Debug output
	print("Found ", work_types.size(), " work types")
	print("Found ", pawns.size(), " pawns")
	
	# Set columns based on work types plus one for pawn names
	grid_container.columns = work_types.size() + 1
	
	# Add empty header in top-left corner
	var empty_header = Label.new()
	empty_header.text = "Pawns"
	empty_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_header.custom_minimum_size.x = 120
	header_container.add_child(empty_header)
	
	# Add work type headers
	for work_type in work_types:
		var header = Label.new()
		header.text = work_type.display_name
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.tooltip_text = work_type_database.get_work_type(work_type.id).description
		header_container.add_child(header)
	
	# Add rows for each pawn
	var row_index = 0
	for pawn in pawns:
		# Create row background for alternating colors
		var row_bg = StyleBoxFlat.new()
		if row_index % 2 == 0:
			row_bg.bg_color = Color(0.15, 0.15, 0.15, 0.5)
		else:
			row_bg.bg_color = Color(0.2, 0.2, 0.2, 0.5)
		row_index += 1
		
		# Add pawn name in first column
		var pawn_label = Label.new()
		pawn_label.text = pawn.pawn_name # Access the pawn_name property
		pawn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		pawn_label.custom_minimum_size.x = 120
		pawn_label.add_theme_stylebox_override("normal", row_bg)
		grid_container.add_child(pawn_label)
		
		# Add priority buttons for each work type
		for work_type in work_types:
			var priority_button = _create_priority_button(pawn.pawn_id, work_type.id)
			priority_button.add_theme_stylebox_override("normal", row_bg.duplicate())
			grid_container.add_child(priority_button)
			
	print("Grid populated with ", grid_container.get_child_count(), " elements")

func _create_priority_button(pawn_id, work_type_id):
	var button = Button.new()
	var priority = work_priority_manager.get_priority(pawn_id, work_type_id)
	
	# Set metadata for identifying the button later
	button.set_meta("pawn_id", pawn_id)
	button.set_meta("work_type_id", work_type_id)
	
	# Set button text based on priority
	_update_button_display(button, priority)
	
	# Set button size and properties
	button.custom_minimum_size = Vector2(50, 40)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Connect button press
	button.pressed.connect(_on_priority_button_pressed.bind(pawn_id, work_type_id, button))
	
	return button

func _update_button_display(button, priority):
	var style = StyleBoxFlat.new()
	style.content_margin_left = 5
	style.content_margin_right = 5
	
	match priority:
		WorkPriorityManager.PRIORITY_DISABLED:
			button.text = ""
			style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
		WorkPriorityManager.PRIORITY_LOW:
			button.text = "1"
			style.bg_color = Color(0.2, 0.2, 0.6, 0.7)
		WorkPriorityManager.PRIORITY_NORMAL:
			button.text = "2"
			style.bg_color = Color(0.2, 0.4, 0.7, 0.7)
		WorkPriorityManager.PRIORITY_HIGH:
			button.text = "3"
			style.bg_color = Color(0.3, 0.5, 0.8, 0.7)
		WorkPriorityManager.PRIORITY_URGENT:
			button.text = "4"
			style.bg_color = Color(0.4, 0.6, 1.0, 0.7)
	
	button.add_theme_stylebox_override("hover", style.duplicate())
	button.add_theme_stylebox_override("pressed", style.duplicate())

func _on_priority_button_pressed(pawn_id, work_type_id, button):
	print("Priority button pressed for pawn ", pawn_id, " work type ", work_type_id)
	var new_priority = work_priority_manager.cycle_priority(pawn_id, work_type_id)
	_update_button_display(button, new_priority)

func _on_priorities_changed(pawn_id, work_type_id):
	# Update the specific button if it exists in our grid
	for child in grid_container.get_children():
		if child is Button and child.has_meta("pawn_id") and child.has_meta("work_type_id"):
			if child.get_meta("pawn_id") == pawn_id and child.get_meta("work_type_id") == work_type_id:
				var priority = work_priority_manager.get_priority(pawn_id, work_type_id)
				_update_button_display(child, priority)
				break
