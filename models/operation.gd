@abstract
class_name Operation
extends RefCounted

@abstract
func apply(tool: VoxelTool) -> void

@abstract
func get_affected_volume() -> AABB


@abstract
func copy() -> Operation


class Sphere extends Operation:
	var radius: float
	var center: Vector3
	var additive: bool

	func apply(tool: VoxelTool) -> void:
		assert(radius > 0.0)
		
		tool.mode = VoxelTool.MODE_ADD if additive else VoxelTool.MODE_REMOVE
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
		op.additive = additive
		
		return op
