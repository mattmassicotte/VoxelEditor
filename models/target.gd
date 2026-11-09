class_name Target
extends RefCounted

var node: VoxelNode = null:
	set = set_node

var tool: VoxelTool = null
var location: Vector3 = Vector3.ZERO
	
	
func _update_tool() -> void:
	if is_instance_valid(node) == false:
		tool = null
		return
	
	tool = node.get_voxel_tool()	


func set_node(new_node: VoxelNode) -> void:
	var update_needed = node != new_node
	node = new_node
		
	if update_needed:
		_update_tool()


func get_terrain_textures() -> TextureLayered:
	if node is VoxelLodTerrain == false:
		return null

	var shader_material := node.material as ShaderMaterial
	if shader_material == null:
		print("[VoxelEditor] expected a ShaderMaterial")
		return null

	var layered := shader_material.get_shader_parameter("u_albedo_array") as TextureLayered
	if layered == null:
		print("[VoxelEditor] expected a TextureLayered from u_albedo_array")
		return null
	
	return layered


class AbsolutePosition extends Target:
	
	var distance: float = 20.0


	func update_location(p_viewport_camera: Camera3D) -> void:
		var viewport := p_viewport_camera.get_viewport()

		var mouse_pos := viewport.get_mouse_position()
		var ray_length := distance
		var ray_origin := p_viewport_camera.project_ray_origin(mouse_pos)
	
		location = ray_origin + p_viewport_camera.project_ray_normal(mouse_pos) * ray_length
