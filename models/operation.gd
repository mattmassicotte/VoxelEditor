@abstract
class_name Operation
extends RefCounted

var config := ToolConfiguration.new()

@abstract
func cursor_location_updated(viewport_camera: Camera3D, target: Target, apply: bool) -> void

@abstract
func cursor_exited() -> void

@abstract
func get_affected_volume() -> AABB

#@abstract
#func copy() -> Operation

@abstract
func get_name() -> String


@abstract
class AbsoluteLocationOperation extends Operation:
	var distance: float
	var location: Vector3
	
	
	func cursor_location_updated(viewport_camera: Camera3D, target: Target, apply: bool) -> void:
		assert(distance > 0.0)

		var viewport := viewport_camera.get_viewport()

		var mouse_pos := viewport.get_mouse_position()
		var ray_length := distance
		var ray_origin := viewport_camera.project_ray_origin(mouse_pos)
	
		location = ray_origin + viewport_camera.project_ray_normal(mouse_pos) * ray_length


#class AddSphere extends Sphere:
#
#
	#func get_name() -> String:
		#return "<add_sphere %f>" % radius
#
	#func apply(tool: VoxelTool) -> void:
		#tool.mode = VoxelTool.MODE_ADD
		#
		#super.apply(tool)
#
#
	#func copy() -> Operation:
		#var op = AddSphere.new()
		#
		#op.radius = radius
		#op.center = center
		#
		#return op
#
#
#class RemoveSphere extends Sphere:
#
#
	#func get_name() -> String:
		#return "<remove_sphere %f>" % radius
#
	#func apply(tool: VoxelTool) -> void:
		#tool.mode = VoxelTool.MODE_REMOVE
		#
		#super.apply(tool)
#
#
	#func copy() -> Operation:
		#var op = RemoveSphere.new()
		#
		#op.radius = radius
		#op.center = center
		#
		#return op
#
#
#class PaintSphere extends Sphere:
#
	#var index: int
	#var falloff: float
	#var opacity: float
#
#
	#func get_name() -> String:
		#return "<paint_sphere %f>" % radius
#
#
	#func apply(tool: VoxelTool) -> void:
		#tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		#tool.texture_index = index
		#tool.texture_falloff = falloff
		#tool.texture_opacity = opacity
		#
		#super.apply(tool)
#
#
	#func copy() -> Operation:
		#var op = PaintSphere.new()
		#
		#op.radius = radius
		#op.center = center
		#
		#op.index = index
		#op.falloff = falloff
		#op.opacity = opacity
		#
		#return op
