class_name AbsoluteSphereOperation
extends SphereOperation

var distance: float
var _additive: bool


func _init(p_additive: bool):
	super()
	_additive = p_additive
		
	if _additive:
		color = Color(0.1, 0.7, 0.1, 0.3)
	else:
		color = Color(0.7, 0.1, 0.1, 0.3)


func cursor_location_updated(viewport_camera: Camera3D, target: Target, apply: bool) -> void:
	_calculate_location(viewport_camera, target)
	_update_indicator(viewport_camera.get_viewport())

	if apply == false:
		return

	target.tool.mode = VoxelTool.MODE_ADD if _additive else VoxelTool.MODE_REMOVE
	target.tool.do_sphere(location, radius)

	# a second pass is necessary if we are not using the first texture
	if _additive and target.tool.texture_index != 0:
		target.tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		target.tool.do_sphere(location, radius * 1.5) # this is totally bogus


func get_name() -> String:
	var mode_name := "add" if _additive else "remove"

	return "<%s absolute sphere %f, %f>" % [mode_name, radius, distance]


func _calculate_location(viewport_camera: Camera3D, target: Target) -> void:
	assert(distance > 0.0)

	var viewport := viewport_camera.get_viewport()

	var mouse_pos := viewport.get_mouse_position()
	var ray_length := distance
	var ray_origin := viewport_camera.project_ray_origin(mouse_pos)
	
	location = ray_origin + viewport_camera.project_ray_normal(mouse_pos) * ray_length
