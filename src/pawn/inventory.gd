class_name Inventory
extends Resource

var items = {} # Dictionary to store resources and their amounts

# Add resources to inventory
func add_item(resource_type, amount):
    if resource_type in items:
        items[resource_type] += amount
    else:
        items[resource_type] = amount
    return true

# Check if inventory has a specific resource
func has_item(resource_type, amount = 1):
    return resource_type in items and items[resource_type] >= amount

# Remove resources from inventory
func remove_item(resource_type, amount):
    if not has_item(resource_type, amount):
        return false
    
    items[resource_type] -= amount
    
    # Remove the entry if amount is zero
    if items[resource_type] <= 0:
        items.erase(resource_type)
    
    return true

# Get the current amount of a specific resource
func get_item_count(resource_type):
    return items.get(resource_type, 0)
