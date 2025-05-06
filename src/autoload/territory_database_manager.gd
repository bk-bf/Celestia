extends Node

var territory_database = TerritoryDatabase.new()

func _ready():
    # Initialize any additional setup here
    pass

func get_monster_types():
    return territory_database.get_monster_types()

func get_territory_thresholds(monster_type):
    return territory_database.get_territory_thresholds(monster_type)
