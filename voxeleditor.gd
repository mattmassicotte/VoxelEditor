@tool
extends EditorPlugin


var _current_brush: Brush = null
var _current_mode: EditMode = null
var _sphere_brush := Brush.Sphere.new()
var _current_operation: Operation
var _target := Target.AbsolutePosition.new()
var _tool_active: bool = false
var _toolbar: Toolbar
var _matter_settings: MatterSettings
var _paint_mode_settings: PaintSettings
var _sphere_settings: SphereSettings


func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	pass


func _enter_tree() -> void:
	var toolbar_scene = preload("res://addons/VoxelEditor/scenes/toolbar.tscn")
	_toolbar = toolbar_scene.instantiate()
	_toolbar.scene_file_path = "" # make local
	_toolbar.tool_changed.connect(_on_tool_changed)

	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, _toolbar)
	
	# add cursor settings
	var absolute_cursor_settings_scene = preload("res://addons/VoxelEditor/scenes/cursor_settings.tscn")
	var absolute_cursor_settings: CursorSettings = absolute_cursor_settings_scene.instantiate()
	absolute_cursor_settings.scene_file_path = ""
	absolute_cursor_settings.cursor_distance_changed.connect(_on_cursor_distance_changed)
	
	_toolbar.install_cursor_settings(absolute_cursor_settings)

	var sphere_settings_scene = preload("res://addons/VoxelEditor/scenes/sphere_settings.tscn")
	_sphere_settings = sphere_settings_scene.instantiate()
	_sphere_settings.scene_file_path = ""
	_sphere_settings.radius_changed.connect(func (value: float):
		_current_brush.set_radius(value)
		_current_operation.radius = value
	)

	# mode settings
	var paint_mode_settings_scene = preload("res://addons/VoxelEditor/scenes/paint_settings.tscn")
	_paint_mode_settings = paint_mode_settings_scene.instantiate()
	_paint_mode_settings.scene_file_path = ""
	_paint_mode_settings.texture_selected.connect(func (value: int):
		_current_operation.config.texture_index = value
	)
	
	var matter_setings_scene = preload("res://addons/VoxelEditor/scenes/matter_settings.tscn")
	_matter_settings = matter_setings_scene.instantiate()
	_matter_settings.scene_file_path = ""
	_matter_settings.matter_settings_changed.connect(func (strength: float, scale: float):
		_current_operation.config.sdf_strength = strength
		_current_operation.config.sdf_scale = scale
	)

	# simulate a change to establish initial state
	_on_tool_changed(_toolbar.mode, _toolbar.brush)


func _exit_tree() -> void:
	if is_instance_valid(_current_brush):
		_current_brush.deactivate()

	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, _toolbar)
	_toolbar.queue_free()


func _handles(p_object: Object) -> bool:
	return p_object is VoxelNode


func _edit(p_object: Object) -> void:
	_target.node = p_object if p_object is VoxelNode else null
	_toolbar.visible = is_instance_valid(_target.node)

	_on_target_node_changed()


func _on_target_node_changed() -> void:
	var valid = is_instance_valid(_target.node)

	if valid:
		_current_brush.activate(_target, _toolbar.mode)

		# this depends on the target node only
		_paint_mode_settings.target_updated(_target)
	else:
		_current_brush.deactivate()


func _on_cursor_distance_changed(distance: float) -> void:
	_target.distance = distance
	
	if is_instance_valid(_target.node):
		_on_target_updated(_target.node.get_viewport())


func _on_target_updated(viewport: SubViewport) -> void:
	_current_operation.update(_target)
	_current_brush.preview(_target, _toolbar.mode, viewport)


func _forward_3d_gui_input(p_viewport_camera: Camera3D, p_event: InputEvent) -> AfterGUIInput:
	if p_event is InputEventMouseMotion:
		_target.update_location(p_viewport_camera)
		_on_target_updated(p_viewport_camera.get_viewport())
			
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


func _on_tool_changed(mode: Toolbar.Mode, brush: Toolbar.Brush) -> void:
	if _current_brush != null:
		_current_brush.deactivate()

	match brush:
		Toolbar.Brush.SPHERE:
			_current_brush = _sphere_brush
			_toolbar.install_brush_settings(_sphere_settings)
			var new_op = Operation.Sphere.new()
			
			new_op.radius = _sphere_settings.radius
			new_op.center = _target.location
			
			if _current_operation != null:
				new_op.config = _current_operation.config
			else:
				new_op.config = ToolConfiguration.new()
			
			_current_operation = new_op

	match mode:
		Toolbar.Mode.ADD:
			_current_operation.config.mode = VoxelTool.Mode.MODE_ADD
			_toolbar.install_mode_settings(_matter_settings)
		Toolbar.Mode.REMOVE:
			_current_operation.config.mode = VoxelTool.Mode.MODE_REMOVE
			_toolbar.install_mode_settings(_matter_settings)
		Toolbar.Mode.PAINT:
			_current_operation.config.mode = VoxelTool.Mode.MODE_TEXTURE_PAINT
			_toolbar.install_mode_settings(_paint_mode_settings)

	if _current_brush != null && _target.node != null:
		_current_brush.activate(_target, mode)
			

func _apply_active_tool() -> void:
	var op = _current_operation.copy()

	var aabb = op.get_affected_volume()
	if _target.tool.is_area_editable(aabb) == false:
		print("voxel area not editable")
		return
		
	var undo_redo := get_undo_redo()

	var name = op.get_name()

	undo_redo.create_action("Apply %s" % name)

	var buffer = _target.node.format.create_buffer(aabb.size)
	const mask = VoxelBuffer.CHANNEL_SDF | VoxelBuffer.CHANNEL_INDICES | VoxelBuffer.CHANNEL_WEIGHTS
	
	_target.tool.copy(aabb.position, buffer, mask, true)
	
	undo_redo.add_do_method(op, "apply", _target.tool)
	undo_redo.add_undo_method(self, "_apply_buffer", aabb.position, mask, buffer)
	
	undo_redo.commit_action()


func _apply_buffer(location: Vector3, mask: int, buffer: VoxelBuffer) -> void:
	_target.tool.paste(location, buffer, mask)
