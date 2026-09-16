@abstract
class_name Operation
extends RefCounted

@abstract
func apply(tool: VoxelTool) -> void

@abstract
func get_affected_volume() -> AABB


@abstract
func copy() -> Operation

@abstract
func get_name() -> String


@abstract
class Sphere extends Operation:
	var radius: float
	var center: Vector3

	func apply(tool: VoxelTool) -> void:
		assert(radius > 0.0)
		
		tool.do_sphere(center, radius)


	func get_affected_volume() -> AABB:
		assert(radius > 0.0)

		var box = AABB()
		
		box.size = Vector3(radius * 2.0 + 1.0, radius * 2.0 + 1.0, radius * 2.0 + 1.0).ceil()
		box.position = Vector3(center.x - radius, center.y - radius, center.z - radius).floor()
		
		return box


class AddSphere extends Sphere:
	func get_name() -> String:
		return "<add_sphere %f>" % radius

	func apply(tool: VoxelTool) -> void:
		tool.mode = VoxelTool.MODE_ADD
		
		super.apply(tool)


	func copy() -> Operation:
		var op = AddSphere.new()
		
		op.radius = radius
		op.center = center
		
		return op


class PaintSphere extends Sphere:
	func get_name() -> String:
		return "<paint_sphere %f>" % radius
		
	func apply(tool: VoxelTool) -> void:
		tool.mode = VoxelTool.MODE_TEXTURE_PAINT
		tool.texture_index = 0
		#tool.texture_falloff = 0.01
		tool.texture_opacity = 1.0
		
		super.apply(tool)


	func copy() -> Operation:
		var op = PaintSphere.new()
		
		op.radius = radius
		op.center = center
		
		return op
