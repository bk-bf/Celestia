class_name Inventory
extends Resource

var items = {} # Dictionary to store resources and their amounts
var owner_name = "" # Name of the pawn that owns this inventory

# Set the owner name for better logging
func set_owner(name):
    owner_name = name

# Get the current amount of a specific resource
func get_item_count(resource_type):
    return items.get(resource_type, 0)

# Add resources to inventory
func add_item(resource_type, amount):
    var previous_amount = get_item_count(resource_type)
    
    if resource_type in items:
        items[resource_type] += amount
    else:
        items[resource_type] = amount
    
    # Log the inventory update
    if DebugLogger.instance:
        DebugLogger.instance.log_inventory_update(
            owner_name,
            resource_type,
            amount,
            items[resource_type]
        )
    
    return true
