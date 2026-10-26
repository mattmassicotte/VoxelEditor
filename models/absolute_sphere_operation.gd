class_name AbsoluteSphereOperation
extends Operation.AbsoluteLocationOperation

var radius: float:
	set(value):
		radius = value
		_indicator.scale = Vector3(radius * 2.0, radius * 2.0, radius * 2.0)
var _additive: bool
var _indicator: MeshInstance3D
	
	
func _init(p_additive: bool):
	var indicator_scene = preload("res://addons/VoxelEditor/scenes/indicator.tscn")
	_indicator = indicator_scene.instantiate()
	_indicator.scene_file_path = "" # make local
	_additive = p_additive
		
	if _additive:
		_indicator.mesh.material.albedo_color = Color(0.1, 0.7, 0.1, 0.3)
	else:
		_indicator.mesh.material.albedo_color = Color(0.7, 0.1, 0.1, 0.3)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			cursor_exited()
			_indicator.queue_free()


func cursor_exited():
	var parent = _indicator.get_parent()
	if parent != null:
		parent.remove_child(_indicator)


func cursor_location_updated(viewport_camera: Camera3D, target: Target, apply: bool) -> void:
	super.cursor_location_updated(viewport_camera, target, apply)

	assert(radius > 0.0)
		
	_update_indicator(viewport_camera.get_viewport(), target.tool.mode)

	if apply == false:
		return

	config.apply(target.tool)
	target.tool.mode = VoxelTool.MODE_ADD if _additive else VoxelTool.MODE_REMOVE
	target.tool.do_sphere(location, radius)

	# a second pass is necessary if we are not using the first texture
	if _additive and target.tool.texture_index != 0:
		target.tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		target.tool.do_sphere(location, radius * 2.0)


func get_affected_volume() -> AABB:
	assert(radius > 0.0)

	var box = AABB()
		
	box.size = Vector3(radius * 2.0 + 1.0, radius * 2.0 + 1.0, radius * 2.0 + 1.0).ceil()
	box.position = Vector3(location.x - radius, location.y - radius, location.z - radius).floor()
		
	return box


func get_name() -> String:
	var mode_name := "add" if _additive else "remove"

	return "<%s absolute sphere %f, %f>" % [mode_name, radius, distance]


func _update_indicator(viewport: Viewport, mode: VoxelTool.Mode):
	_install_indicator_if_needed(viewport)
	_indicator.scale = Vector3(radius * 2.0, radius * 2.0, radius * 2.0)
	_indicator.position = location


func _install_indicator_if_needed(viewport: Viewport):
	var current_parent = _indicator.get_parent()
	
	if current_parent == viewport:
		return
		
	if current_parent != null:
		current_parent.remove_child(_indicator)

	viewport.add_child(_indicator)
