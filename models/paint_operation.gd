class_name PaintOperation
extends Operation

var radius: float:
	set(value):
		radius = value
		_indicator.scale = Vector3(radius * 2.0, radius * 2.0, radius * 2.0)
var _indicator: MeshInstance3D


func _init():
	var indicator_scene = preload("res://addons/VoxelEditor/scenes/indicator.tscn")
	_indicator = indicator_scene.instantiate()
	_indicator.scene_file_path = "" # make local
		
	_indicator.mesh.material.albedo_color = Color(0.0, 0.1, 0.8, 0.3)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			_indicator.queue_free()


func cursor_location_updated(viewport_camera: Camera3D, target: Target, apply: bool) -> void:
	var viewport := viewport_camera.get_viewport()

	var mouse_pos := viewport.get_mouse_position()
	var normal = viewport_camera.project_ray_normal(mouse_pos)
	
	var result = target.tool.raycast(viewport_camera.position, normal, 100.0)
	if result == null:
		cursor_exited()
		return

	_indicator.position = result.position
	
	_update_indicator(viewport_camera.get_viewport())


func cursor_exited() -> void:
	var parent = _indicator.get_parent()
	if parent != null:
		parent.remove_child(_indicator)


func get_affected_volume() -> AABB:
	return AABB()


func get_name() -> String:
	return "<paint sphere %f>" % [radius]

func _update_indicator(viewport: Viewport):
	_install_indicator_if_needed(viewport)
	_indicator.scale = Vector3(radius * 2.0, radius * 2.0, radius * 2.0)


func _install_indicator_if_needed(viewport: Viewport):
	var current_parent = _indicator.get_parent()
	
	if current_parent == viewport:
		return
		
	if current_parent != null:
		current_parent.remove_child(_indicator)

	viewport.add_child(_indicator)
