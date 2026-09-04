@tool
extends EditorPlugin


var _active_tool: Tool = null
var _sphere_tool := Tool.Sphere.new()
var _target := Target.AbsolutePosition.new()
var _tool_active: bool = false
var _toolbar: Toolbar

func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	pass


func _enter_tree() -> void:
	var toolbar_scene = preload("res://addons/voxeleditor/scenes/toolbar.tscn")
	_toolbar = toolbar_scene.instantiate()
	_toolbar.scene_file_path = "" # make local

	_toolbar.item_selected.connect(_toolbar_item_selected)

	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, _toolbar)
	
	# add all the per-tool settings
	_install_settings(_sphere_tool.get_settings_node())

	_toolbar_item_selected(Toolbar.ItemKind.ADD)


func _exit_tree() -> void:
	# trigger a target node change to clear out all related editor state
	_target.node = null
	_on_target_node_changed()

	_uninstall_settings(_sphere_tool.get_settings_node())

	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, _toolbar)
	_toolbar.queue_free()


func _install_settings(settings_node: Node) -> void:
	if is_instance_valid(settings_node) == false:
		return
		
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, settings_node)


func _uninstall_settings(settings_node: Node) -> void:
	if is_instance_valid(settings_node) == false:
		return

	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, settings_node)

func _handles(p_object: Object) -> bool:
	return p_object is VoxelNode


func _edit(p_object: Object) -> void:
	_target.node = p_object if p_object is VoxelNode else null
	_toolbar.visible = is_instance_valid(_target.node)

	_on_target_node_changed()


func _on_target_node_changed() -> void:
	var valid = is_instance_valid(_target.node)

	if valid:
		_active_tool.activate(_target)
	else:
		_active_tool.deactivate()

	var settings = _active_tool.get_settings_node()
	if settings != null:
		settings.visible = valid


func _forward_3d_gui_input(p_viewport_camera: Camera3D, p_event: InputEvent) -> AfterGUIInput:
	if p_event is InputEventMouseMotion:
		_target.update_location(p_viewport_camera)
		_active_tool.preview(_target, p_viewport_camera.get_viewport())
			
	if p_event is InputEventMouseButton and p_event.button_index == MOUSE_BUTTON_LEFT:
		if p_event.is_pressed():
			_tool_active = true
			_apply_active_tool()
			return AfterGUIInput.AFTER_GUI_INPUT_STOP
		else:
			_tool_active = false
	
	if p_event is InputEventMouseMotion and _tool_active:
		_apply_active_tool()
		return AfterGUIInput.AFTER_GUI_INPUT_STOP 
	
	return AfterGUIInput.AFTER_GUI_INPUT_PASS


func _toolbar_item_selected(kind: Toolbar.ItemKind) -> void:
	if _active_tool != null:
		_active_tool.deactivate()

	match kind:
		Toolbar.ItemKind.ADD:
			_active_tool = _sphere_tool
			_active_tool.additive = true

		Toolbar.ItemKind.REMOVE:
			_active_tool = _sphere_tool
			_active_tool.additive = false
	
	if _active_tool != null && _target.node != null:
		_active_tool.activate(_target)


func _apply_active_tool() -> void:
	print("_apply_active_tool")
	assert(_active_tool != null)
	assert(_target != null)
	
	var op = _active_tool.make_operation(_target)

	var aabb = op.get_affected_volume()
	if _target.tool.is_area_editable(aabb) == false:
		print("voxel area not editable")
		return
		
	var undo_redo := get_undo_redo()

	undo_redo.create_action("Apply Voxel Operation")

	var buffer = _target.node.format.create_buffer(aabb.size)
	const mask = VoxelBuffer.CHANNEL_SDF | VoxelBuffer.CHANNEL_INDICES | VoxelBuffer.CHANNEL_WEIGHTS
	
	_target.tool.copy(aabb.position, buffer, mask, true)
	
	undo_redo.add_do_method(op, "apply", _target.tool)
	undo_redo.add_undo_method(self, "_apply_buffer", aabb.position, mask, buffer)
	
	undo_redo.commit_action()


func _apply_buffer(location: Vector3, mask: int, buffer: VoxelBuffer) -> void:
	_target.tool.paste(location, buffer, mask)
