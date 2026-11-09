class_name PaintOperation
extends SphereOperation


func _init():
	super()
	color = Color(0.0, 0.1, 0.8, 0.3)


func cursor_location_updated(viewport_camera: Camera3D, target: Target, apply: bool) -> void:
	if _calculate_location(viewport_camera, target) == false:
		cursor_exited()
		return

	_update_indicator(viewport_camera.get_viewport())

	if apply == false:
		return

	target.tool.mode = VoxelTool.MODE_TEXTURE_PAINT
	target.tool.do_sphere(location, radius)


func get_name() -> String:
	return "<paint sphere %f>" % [radius]


func _calculate_location(viewport_camera: Camera3D, target: Target) -> bool:
	var viewport := viewport_camera.get_viewport()

	var mouse_pos := viewport.get_mouse_position()
	var normal = viewport_camera.project_ray_normal(mouse_pos)
	
	var result = target.tool.raycast(viewport_camera.position, normal, 100.0)
	if result == null:
		return false

	location = result.position
	
	return true
