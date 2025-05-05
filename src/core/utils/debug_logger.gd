# DebugLogger.gd
extends Node
class_name DebugLogger

# Singleton instance
static var instance: DebugLogger

# Resource statistics
var harvested_resources = {}

func _ready():
    instance = self
    
func log_resource_harvested(pawn_name: String, resource_type: String, amount: int, position: Vector2i):
    print("[HARVEST] Pawn: %s harvested %d %s at position (%d, %d)" %
          [pawn_name, amount, resource_type, position.x, position.y])
    
    # Update statistics
    if not harvested_resources.has(resource_type):
        harvested_resources[resource_type] = 0
    
    harvested_resources[resource_type] += amount
    
    # Log total statistics
    print("[STATS] Total %s harvested: %d" % [resource_type, harvested_resources[resource_type]])
    
func log_inventory_update(pawn_name: String, resource_type: String, amount: int, total: int):
    print("[INVENTORY] Pawn: %s added %d %s to inventory (Total: %d)" %
          [pawn_name, amount, resource_type, total])

func print_harvesting_statistics():
    print("\n=== CELESTIA HARVESTING STATISTICS ===")
    for resource_type in harvested_resources:
        print("- %s harvested: %d units" % [resource_type.capitalize(), harvested_resources[resource_type]])
    print("===============================")
