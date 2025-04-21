@tool
extends GraphEdit


signal connection_update_requested
signal save_requested

var attached_elements: Dictionary

func _init() -> void:
	for cast in GaeaValue.get_cast_list():
		add_valid_connection_type(cast[0], cast[1])


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	add_theme_color_override(&"connection_rim_color", Color("141414"))


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	delete_nodes(nodes)


func delete_nodes(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var node: GraphElement = get_node(NodePath(node_name))
		if node is GaeaGraphNode:
			if node.resource.is_output():
				continue
			for connection in node.connections:
				disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			node.removed.emit()
		elif node is GraphFrame:
			for attached in get_attached_nodes_of_frame(node.name):
				attached_elements.erase(attached)
		node.queue_free()
		await node.tree_exited

	connection_update_requested.emit()
	save_requested.emit()


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if is_nodes_connected_relatively(from_node, to_node):
		return

	var target_node: GaeaGraphNode = get_node(NodePath(to_node))

	if target_node is GaeaGraphNode:
		for connection in target_node.connections:
			if connection.to_port == to_port:
				disconnection_request.emit(
					connection.from_node,
					connection.from_port,
					connection.to_node,
					connection.to_port
				)
	else:
		for connection: Dictionary in get_connection_list():
			if connection.to_node == to_node and connection.to_port == to_port:
				disconnection_request.emit(
					connection.from_node,
					connection.from_port,
					connection.to_node,
					connection.to_port
				)

	connect_node(from_node, from_port, to_node, to_port)
	connection_update_requested.emit()

	get_node(NodePath(from_node)).notify_connections_updated.call_deferred()
	target_node.notify_connections_updated.call_deferred()

	save_requested.emit()

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	connection_update_requested.emit()

	get_node(NodePath(from_node)).notify_connections_updated.call_deferred()
	get_node(NodePath(to_node)).notify_connections_updated.call_deferred()

	save_requested.emit()

func remove_invalid_connections() -> void:
	for connection in get_connection_list():
		var to_node: GraphNode = get_node(NodePath(connection.to_node))
		var from_node: GraphNode = get_node(NodePath(connection.from_node))

		if not is_instance_valid(from_node) or not is_instance_valid(to_node):
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			continue

		if to_node.get_input_port_count() <= connection.to_port:
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			continue

		if from_node.get_output_port_count() <= connection.from_port:
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			continue

	save_requested.emit()

func is_nodes_connected_relatively(from_node: StringName, to_node: StringName) -> bool:
	var nodes_to_check: Array[StringName] = [from_node]
	while nodes_to_check.size() > 0:
		var node_name = nodes_to_check.pop_front()
		var node: GaeaGraphNode = get_node(NodePath(node_name))
		if node is GaeaGraphNode:
			for connection in node.connections:
				nodes_to_check.append(connection.from_node)
				if connection.from_node == to_node:
					return true
	return false

func get_selected() -> Array:
	return get_children().filter(func(child: Node) -> bool:
		return child is GraphElement and child.selected
	)


func get_selected_names() -> Array[StringName]:
	var selected := get_selected()
	var array: Array[StringName]
	for node: Node in selected:
		array.append(node.name)
	return array


func _on_graph_elements_linked_to_frame_request(elements: Array, frame: StringName) -> void:
	for element in elements:
		attach_graph_element_to_frame(element, frame)
		_on_element_attached_to_frame(element, frame)
	save_requested.emit.call_deferred()


func _on_element_attached_to_frame(element: StringName, frame: StringName) -> void:
	attached_elements.set(element, frame)
	save_requested.emit()


func _is_node_hover_valid(from_node: StringName, _from_port: int, to_node: StringName, _to_port: int) -> bool:
	if from_node == to_node:
		return false
	return true


## This function converts a local position to a grid position based on the current zoom level and scroll offset.
## It also applies snapping if enabled in the GraphEdit.
func local_to_grid(local_position: Vector2, grid_offset: Vector2 = Vector2.ZERO, enable_snapping: bool = true) -> Vector2:
	local_position = (local_position + scroll_offset) / zoom
	local_position += grid_offset
	if enable_snapping and snapping_enabled:
		return local_position.snapped(Vector2.ONE * snapping_distance)
	else:
		return local_position
