# PawnInfoUI.gd
extends Control
class_name PawnInfoUI

# Reference to UI elements
@onready var trait_list = get_node("/root/Game/Main/PawnInfoUI/MarginContainer/VBoxContainer/TraitList") # this is a RichTextLabel in my scene

# Current selected pawn
var current_pawn = null

func _ready():
	# Initialize the UI
	if trait_list:
		trait_list.text = "No pawn selected"

# Update the UI when a pawn is selected
func set_selected_pawn(pawn):
	current_pawn = pawn
	update_trait_display()
	
# Update the traits display
func update_trait_display():
	if not trait_list or not current_pawn:
		return
		
	var text = "Traits:\n"
	
	if current_pawn.traits.size() > 0:
		for trait_name in current_pawn.traits:
			var traits = get_node("/root/TraitDatabase").get_trait(trait_name)
			if traits:
				text += "- " + trait_name.capitalize() + ": " + traits["description"] + "\n"
	else:
		text += "- None"
	
	trait_list.text = text
