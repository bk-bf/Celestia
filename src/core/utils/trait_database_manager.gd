extends Node

# This script makes the TraitDatabase accessible globally

var trait_database = TraitDatabase.new()

func _ready():
    # Initialize any additional setup here
    pass

func get_trait(trait_name):
    return trait_database.get_trait(trait_name)

func get_traits_by_category(category):
    return trait_database.get_traits_by_category(category)
