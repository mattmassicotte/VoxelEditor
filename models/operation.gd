@abstract
class_name Operation
extends RefCounted

var config := ToolConfiguration.new()

@abstract
func update(target: Target) -> void

@abstract
func apply(tool: VoxelTool) -> void

@abstract
func get_affected_volume() -> AABB

@abstract
func copy() -> Operation

@abstract
func get_name() -> String


class Sphere extends Operation:

	var radius: float
	var center: Vector3


	func update(target: Target) -> void:
		center = target.location


	func apply(tool: VoxelTool) -> void:
		assert(radius > 0.0)
		
		config.apply(tool)
		tool.do_sphere(center, radius)


	func get_affected_volume() -> AABB:
		assert(radius > 0.0)

		var box = AABB()
		
		box.size = Vector3(radius * 2.0 + 1.0, radius * 2.0 + 1.0, radius * 2.0 + 1.0).ceil()
		box.position = Vector3(center.x - radius, center.y - radius, center.z - radius).floor()
		
		return box


	func copy() -> Operation:
		var op = Sphere.new()
		
		op.radius = radius
		op.center = center
		op.config = config.copy()
		
		return op


	func get_name() -> String:
		var mode_name: String

		match config.mode:
			VoxelTool.Mode.MODE_ADD:
				mode_name = "add"
			VoxelTool.Mode.MODE_REMOVE:
				mode_name = "remove"
			VoxelTool.Mode.MODE_TEXTURE_PAINT:
				mode_name = "paint"

		return "<%s_sphere %f>" % [mode_name, radius]


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
