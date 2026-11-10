class_name SurfaceSphereOperation
extends SphereOperation

enum Mode {
	ADD,
	REMOVE,
	PAINT
}

var mode: Mode
var _last_apply := false

func _init(mode: Mode):
	super()
	self.mode = mode
	
	match mode:
		Mode.ADD:
			color = Color(0.1, 0.7, 0.1, 0.3)
		Mode.REMOVE:
			color = Color(0.7, 0.1, 0.1, 0.3)
		Mode.PAINT:
			color = Color(0.0, 0.1, 0.8, 0.3)


func cursor_location_updated(viewport_camera: Camera3D, target: Target, apply: bool) -> void:
	if _calculate_location(viewport_camera, target, apply) == false:
		cursor_exited()
		return
	
	var drag = _last_apply and apply
	_last_apply = apply

	# disable dragging to prevent undesirable editing behavior
	if drag and mode != Mode.PAINT:
		cursor_exited()
		return

	_update_indicator(viewport_camera.get_viewport())

	if apply == false:
		return
	
	match mode:
		Mode.ADD:
			target.tool.mode = VoxelTool.MODE_ADD
		Mode.REMOVE:
			target.tool.mode = VoxelTool.MODE_REMOVE
		Mode.PAINT:
			target.tool.mode = VoxelTool.MODE_TEXTURE_PAINT

	target.tool.do_sphere(location, radius)


func get_name() -> String:
	var name: String
	
	match mode:
		Mode.ADD:
			name = "add"
		Mode.REMOVE:
			name = "remove"
		Mode.PAINT:
			name = "paint"
			
	return "<%s sphere %f>" % [name, radius]


func _calculate_location(viewport_camera: Camera3D, target: Target, apply: bool) -> bool:
	var space_state = viewport_camera.get_world_3d().direct_space_state
	var mouse_pos := viewport_camera.get_viewport().get_mouse_position()

	var origin := viewport_camera.project_ray_origin(mouse_pos)
	var end := origin + viewport_camera.project_ray_normal(mouse_pos) * 100.0
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result := space_state.intersect_ray(query)
	if result.has("position") == false:
		return false
	
	var hit_point = result["position"]
	
	location = hit_point

	return true
