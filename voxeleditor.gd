@tool
extends EditorPlugin

var _target := Target.AbsolutePosition.new()
var _tool_active: bool = false
var _toolbar_control: ToolbarControl

# Core Plugin Hooks
func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	pass


func _enter_tree() -> void:
	_set_up()


func _exit_tree() -> void:
	_teardown()


# EditorPlugin overrides

func _handles(p_object: Object) -> bool:
	return p_object is VoxelNode


func _edit(p_object: Object) -> void:
	_target.node = p_object

	_toolbar_control.target = _target


func _forward_3d_gui_input(p_viewport_camera: Camera3D, p_event: InputEvent) -> AfterGUIInput:
	# mouse movement
	if p_event is InputEventMouseMotion:
		if _tool_active:
			_toolbar_control.cursor_location_updated(p_viewport_camera, true)
			return AfterGUIInput.AFTER_GUI_INPUT_STOP
	
		_toolbar_control.cursor_location_updated(p_viewport_camera, false)
		return AfterGUIInput.AFTER_GUI_INPUT_PASS
	
	# active left-click
	if p_event is InputEventMouseButton and p_event.button_index == MOUSE_BUTTON_LEFT:
		if p_event.is_pressed():
			_tool_active = true
			_toolbar_control.cursor_location_updated(p_viewport_camera, true)
			return AfterGUIInput.AFTER_GUI_INPUT_STOP
		else:
			_tool_active = false
	
	return AfterGUIInput.AFTER_GUI_INPUT_PASS


# setup/teardown

func _set_up() -> void:
	var toolbar_control_scene = preload("res://addons/VoxelEditor/scenes/toolbar_control.tscn")
	_toolbar_control = toolbar_control_scene.instantiate()
	_toolbar_control.scene_file_path = "" # make local
	_toolbar_control.visible = false
	_toolbar_control.reset.connect(func ():
		_reload()
	)

	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _toolbar_control)
	
	_handle_existing_selection()


func _teardown() -> void:
	_target.node = null
	_toolbar_control.target = null

	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _toolbar_control)
	_toolbar_control.queue_free()
	_toolbar_control = null


func _handle_existing_selection() -> void:
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	
	if selected_nodes.size() != 1:
		return
	
	var selected_node = selected_nodes.front()
	
	if _handles(selected_node):
		_edit(selected_node)


## This is useful for plugin development.
func _reload() -> void:
	print("[VoxelEditor] reload")
	_teardown()
	_set_up()


#func _apply_active_tool() -> void:
	#var op = _current_operation.copy()
#
	#var aabb = op.get_affected_volume()
	#if _target.tool.is_area_editable(aabb) == false:
		#print("voxel area not editable")
		#return
		#
	#var undo_redo := get_undo_redo()
#
	#var name = op.get_name()
#
	#undo_redo.create_action("Apply %s" % name)
#
	#var buffer = _target.node.format.create_buffer(aabb.size)
	#const mask = VoxelBuffer.CHANNEL_SDF | VoxelBuffer.CHANNEL_INDICES | VoxelBuffer.CHANNEL_WEIGHTS
	#
	#_target.tool.copy(aabb.position, buffer, mask, true)
	#
	#undo_redo.add_do_method(op, "apply", _target.tool)
	#undo_redo.add_undo_method(self, "_apply_buffer", aabb.position, mask, buffer)
	#
	#undo_redo.commit_action()
#
#
#func _apply_buffer(location: Vector3, mask: int, buffer: VoxelBuffer) -> void:
	#_target.tool.paste(location, buffer, mask)
