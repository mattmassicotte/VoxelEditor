@abstract
class_name SphereOperation
extends Operation

var color: Color:
	get:
		return _indicator.mesh.material.albedo_color
	set(value):
		_indicator.mesh.material.albedo_color = value
var location: Vector3
var radius: float:
	set(value):
		radius = value
		_indicator.scale = Vector3(radius * 2.0, radius * 2.0, radius * 2.0)
var _indicator: MeshInstance3D
	
	
func _init():
	var indicator_scene = preload("res://addons/VoxelEditor/scenes/indicator.tscn")
	_indicator = indicator_scene.instantiate()
	_indicator.scene_file_path = "" # make local


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			_indicator.queue_free()


func cursor_exited():
	var parent = _indicator.get_parent()
	if parent != null:
		parent.remove_child(_indicator)


func get_affected_volume() -> AABB:
	assert(radius > 0.0)

	var box = AABB()
		
	box.size = Vector3(radius * 2.0 + 1.0, radius * 2.0 + 1.0, radius * 2.0 + 1.0).ceil()
	box.position = Vector3(location.x - radius, location.y - radius, location.z - radius).floor()
		
	return box


func _update_indicator(viewport: Viewport):
	_install_indicator_if_needed(viewport)
	
	assert(radius > 0.0)
	_indicator.scale = Vector3(radius * 2.0, radius * 2.0, radius * 2.0)
	_indicator.position = location


func _install_indicator_if_needed(viewport: Viewport):
	var current_parent = _indicator.get_parent()
	
	if current_parent == viewport:
		return
		
	if current_parent != null:
		current_parent.remove_child(_indicator)

	viewport.add_child(_indicator)
