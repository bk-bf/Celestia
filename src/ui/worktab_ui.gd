class_name WorkTabUI
extends Control

# References
var work_priority_manager = null
var work_type_database = null
var pawn_manager = null

# UI components
var grid_container: GridContainer
var work_type_headers = []
var pawn_rows = {}

# Constants
const PRIORITY_COLORS = {
    0: Color(0.5, 0.5, 0.5, 0.5), # Disabled (gray)
    1: Color(0.2, 0.8, 0.2, 0.5), # Low (green)
    2: Color(0.2, 0.2, 0.8, 0.5), # Normal (blue)
    3: Color(0.8, 0.8, 0.2, 0.5), # High (yellow)
    4: Color(0.8, 0.2, 0.2, 0.5) # Urgent (red)
}

func _ready():
    # Get references
    work_priority_manager = DatabaseManager.work_priority_manager
    work_type_database = DatabaseManager.work_type_database
    pawn_manager = DatabaseManager.pawn_manager
    
    # Connect signals
    if work_priority_manager:
        work_priority_manager.connect("priorities_changed", _on_priorities_changed)
    
    # Initialize UI components
    grid_container = $GridContainer
    
    # Build the UI
    _build_work_tab()

func _build_work_tab():
    # Clear existing UI
    for child in grid_container.get_children():
        child.queue_free()
    
    work_type_headers = []
    pawn_rows = {}
    
    # Get work types and pawns
    var work_types = work_type_database.get_sorted_work_types()
    var pawns = pawn_manager.get_all_pawns()
    
    # Add column headers (work types)
    var header_row = _create_row_container()
    grid_container.add_child(header_row)
    
    # Add pawn header
    var pawn_header = _create_label("Pawn")
    pawn_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    pawn_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    header_row.add_child(pawn_header)
    
    # Add work type headers
    for work_type in work_types:
        var header = _create_work_type_header(work_type.id, work_type.display_name)
        header_row.add_child(header)
        work_type_headers.append(header)
    
    # Add rows for each pawn
    for pawn in pawns:
        _add_pawn_row(pawn)

func _add_pawn_row(pawn):
    var row = _create_row_container()
    grid_container.add_child(row)
    
    # Add pawn label
    var pawn_label = _create_label(pawn.pawn_name)
    pawn_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(pawn_label)
    
    # Add priority buttons for each work type
    var buttons = []
    for work_type_header in work_type_headers:
        var work_type_id = work_type_header.get_meta("work_type_id")
        var priority = work_priority_manager.get_priority(pawn.pawn_id, work_type_id)
        
        var button = _create_priority_button(pawn.pawn_id, work_type_id, priority)
        row.add_child(button)
        buttons.append(button)
    
    # Store row information
    pawn_rows[pawn.pawn_id] = {
        "row": row,
        "label": pawn_label,
        "buttons": buttons
    }

func _create_work_type_header(work_type_id, display_name):
    var header = _create_label(display_name)
    header.set_meta("work_type_id", work_type_id)
    header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return header

func _create_priority_button(pawn_id, work_type_id, priority):
    var button = Button.new()
    button.text = str(priority)
    button.modulate = PRIORITY_COLORS[priority]
    button.set_meta("pawn_id", pawn_id)
    button.set_meta("work_type_id", work_type_id)
    button.connect("pressed", _on_priority_button_pressed.bind(button))
    
    # Add tooltip
    var work_type_data = work_type_database.get_work_type(work_type_id)
    var pawn = pawn_manager.get_pawn(pawn_id)
    
    var tooltip = work_type_data.display_name
    if work_type_data.has("related_skills"):
        tooltip += "\n\nRelated Skills:"
        for skill_name in work_type_data.related_skills:
            var skill_value = pawn.get_modified_stat(skill_name, 1.0)
            tooltip += "\n- " + skill_name.capitalize() + ": " + str(skill_value)
    
    button.tooltip_text = tooltip
    return button

func _on_priority_button_pressed(button):
    var pawn_id = button.get_meta("pawn_id")
    var work_type_id = button.get_meta("work_type_id")
    
    # Cycle priority
    var new_priority = work_priority_manager.cycle_priority(pawn_id, work_type_id)
    
    # Update button
    button.text = str(new_priority)
    button.modulate = PRIORITY_COLORS[new_priority]

func _on_priorities_changed(pawn_id, work_type_id):
    # Update the corresponding button
    if pawn_rows.has(pawn_id):
        var row = pawn_rows[pawn_id]
        
        for i in range(work_type_headers.size()):
            var header = work_type_headers[i]
            if header.get_meta("work_type_id") == work_type_id:
                var button = row.buttons[i]
                var priority = work_priority_manager.get_priority(pawn_id, work_type_id)
                
                button.text = str(priority)
                button.modulate = PRIORITY_COLORS[priority]
                break

# Helper functions
func _create_row_container():
    var container = HBoxContainer.new()
    container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    container.alignment = BoxContainer.ALIGNMENT_CENTER
    return container

func _create_label(text):
    var label = Label.new()
    label.text = text
    return label
