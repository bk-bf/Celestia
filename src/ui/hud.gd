class_name HUD
extends CanvasLayer

# References to UI elements (already created in the scene)
@onready var bottom_menu_bar = $Control/BottomMenuBar
@onready var content_panels = $Control/ContentPanels
@onready var log_window = $Control/LogWindow
@onready var log_entries = $Control/LogWindow/LogScrollContainer/LogEntries
@onready var pawn_menu_bar = $Control/PawnMenuBar
@onready var pawn_info_panel = $Control/ContentPanels/PawnInfoPanel

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

# Signal for log updates
signal log_entry_added(message, type)

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
	#info_button.pressed.connect(_on_info_button_pressed)
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
	#call_deferred("connect_button_signals")
	call_deferred("setup_direct_input")

func setup_direct_input():
	if info_button:
		# Create a simple script for the button
		var script = GDScript.new()
		script.source_code = """
extends Button

func _ready():
	print("Direct button script loaded")

func _pressed():
	print("Button pressed directly")
	get_parent().get_parent().get_parent()._on_info_button_pressed()
"""
		script.reload()
		info_button.set_script(script)

func connect_button_signals():
	if info_button:
		print("Info Button disabled state:", info_button.disabled)
		info_button.disabled = false
		print("Info Button mouse filter:", info_button.mouse_filter)
		info_button.mouse_filter = Control.MOUSE_FILTER_STOP
		print("Info Button focus mode:", info_button.focus_mode)
		info_button.focus_mode = Control.FOCUS_ALL
		info_button.pressed.connect(_on_info_button_pressed)
		print("Info button connected")
		print("Is signal connected:", info_button.is_connected("pressed", _on_info_button_pressed))

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
	
	# Add to log entries
	log_entries.add_child(entry)
	
	# Limit the number of entries
	if log_entries.get_child_count() > 100:
		var oldest = log_entries.get_child(0)
		log_entries.remove_child(oldest)
		oldest.queue_free()

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
	# Simply show the existing PawnInfoPanel
	pawn_info_panel.visible = true
	print("Info button pressed")
	# Update the panel with pawn info
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

# Pawn selection handling
func _on_pawn_selected(pawn_id):
	selected_pawn_id = pawn_id
	
	if pawn_id == -1:
		# No pawn selected, hide the pawn menu bar and info panel
		pawn_menu_bar.visible = false
		pawn_info_panel.visible = false
	else:
		# Pawn selected, show ONLY the pawn menu bar, not the info panel
		pawn_menu_bar.visible = true
		pawn_info_panel.visible = false
		
		# Add log entry about selection
		var pawn = pawn_manager.get_pawn(pawn_id)
		if pawn:
			emit_signal("log_entry_added", "Selected " + pawn.pawn_name, "info")

func update_pawn_info(pawn_id):
	# Clear any existing children first
	for child in pawn_info_panel.get_children():
		if child.name == "InfoLabel":
			child.queue_free()
	
	var pawn = pawn_manager.get_pawn(pawn_id)
	if not pawn:
		return
	
	# Create a label with basic pawn info
	var label = Label.new()
	label.name = "InfoLabel"
	
	# Build the pawn info text
	var pawn_info = "Name: " + pawn.pawn_name + "\n"
	pawn_info += "Gender: " + pawn.pawn_gender + "\n"
	pawn_info += "Strength: " + str(pawn.strength) + "\n"
	pawn_info += "Dexterity: " + str(pawn.dexterity) + "\n"
	pawn_info += "Intelligence: " + str(pawn.intelligence) + "\n"
	
	# Add job info if available
	if pawn.current_job:
		pawn_info += "\nCurrent job: " + pawn.current_job.job_to_string()
	else:
		pawn_info += "\nCurrent job: None"
	
	label.text = pawn_info
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Add the label to the panel
	pawn_info_panel.add_child(label)

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
