extends Node

# The actual MapData resource instance
var map_data = null
var save_path = "user://map_data.tres"

func _ready():
    # Try to load existing map data first
    if FileAccess.file_exists(save_path):
        map_data = ResourceLoader.load(save_path)
        print("Loaded existing map data")
    else:
        # Create new map data if none exists
        const MapDataFile = preload("res://src/world/terrain/map_data.gd")
        map_data = MapDataFile.new()
        print("Created new map data")

func save_map(custom_path = null):
    var path = custom_path if custom_path else save_path
    if map_data:
        var result = map_data.save_to_file(path)
        print("Map saved with result: " + str(result))
        return result
    return ERR_UNCONFIGURED

# redundant
#func save_current_map():
 #   if map_data:
  #      var save_path = "res://resources/maps/test_map.tres"
   #     var err = map_data.save_to_file(save_path)
   #     print("Map saved with result: ", err)
   #     return err
   # return ERR_UNCONFIGURED
    
func generate_new_map(width, height, seed_value):
    # Create new map data
    const MapDataFile = preload("res://src/world/terrain/map_data.gd")
    map_data = MapDataFile.new()
    
    # Initialize with parameters
    map_data.initialize(width, height, seed_value)
    
    # Save the newly generated map
    save_map()
