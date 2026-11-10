@abstract
class_name BoxOperation
extends Operation

var color: Color:
	get:
		return _indicator.mesh.material.albedo_color
	set(value):
		_indicator.mesh.material.albedo_color = value
var height: float
var length: float
var location: Vector3
var width: float
var _indicator: MeshInstance3D
	
	
func _init():
	var indicator_scene = preload("res://addons/VoxelEditor/scenes/box_indicator.tscn")
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
	# no transforms applied, and don't forget that order matters here
	var aabb := _indicator.get_aabb()
	
	aabb = _indicator.global_transform * aabb
	
	aabb.position = aabb.position.ceil()
	aabb.size = aabb.size.floor()
	
	return aabb


func _update_indicator(viewport: Viewport):
	_install_indicator_if_needed(viewport)
	
	assert(height > 0.0)
	assert(length > 0.0)
	assert(width > 0.0)
	
	_indicator.scale = Vector3(length, height, width)
	_indicator.position = location


func _install_indicator_if_needed(viewport: Viewport):
	var current_parent = _indicator.get_parent()
	
	if current_parent == viewport:
		return
		
	if current_parent != null:
		current_parent.remove_child(_indicator)

	viewport.add_child(_indicator)
