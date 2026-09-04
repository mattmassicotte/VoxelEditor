class_name Target
extends RefCounted


var node: VoxelNode = null:
	set(value):
		var update_needed = node != value
		node = value
		
		if update_needed:
			_update_tool()

var tool: VoxelTool = null
var location: Vector3 = Vector3.ZERO


func _update_tool() -> void:
	if is_instance_valid(node) == false:
		tool = null
		return
	
	tool = node.get_voxel_tool()


class AbsolutePosition extends Target:
	var distance: float = 20.0


	func update_location(p_viewport_camera: Camera3D) -> void:
		var viewport := p_viewport_camera.get_viewport()

		var mouse_pos := viewport.get_mouse_position()
		var ray_length := distance
		var ray_origin := p_viewport_camera.project_ray_origin(mouse_pos)
	
		location = ray_origin + p_viewport_camera.project_ray_normal(mouse_pos) * ray_length
