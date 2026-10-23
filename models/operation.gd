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


class Sphere extends AbsoluteLocationOperation:

	var _additive: bool
	var radius: float:
		set(value):
			radius = value
			_indicator.scale = Vector3(radius * 2.0, radius * 2.0, radius * 2.0)
	var _indicator: MeshInstance3D
	
	
	func _init(p_additive: bool):
		var indicator_scene = preload("res://addons/VoxelEditor/scenes/indicator.tscn")
		_indicator = indicator_scene.instantiate()
		_indicator.scene_file_path = "" # make local
		
		_additive = p_additive
		
		if _additive:
			_indicator.mesh.material.albedo_color = Color(0.1, 0.7, 0.1, 0.3)
		else:
			_indicator.mesh.material.albedo_color = Color(0.7, 0.1, 0.1, 0.3)


	func cursor_exited():
		var parent = _indicator.get_parent()
		if parent != null:
			parent.remove_child(_indicator)


	func cursor_location_updated(viewport_camera: Camera3D, target: Target, apply: bool) -> void:
		super.cursor_location_updated(viewport_camera, target, apply)

		assert(radius > 0.0)
		
		_update_indicator(viewport_camera.get_viewport(), target.tool.mode)

		if apply == false:
			return

		config.apply(target.tool)
		target.tool.mode = VoxelTool.MODE_ADD if _additive else VoxelTool.MODE_REMOVE
		target.tool.do_sphere(location, radius)

		# a second pass is necessary if we are not using the first texture
		if _additive && target.tool.texture_index != 0:
			target.tool.mode = VoxelTool.MODE_TEXTURE_PAINT
			target.tool.do_sphere(location, radius)


	func get_affected_volume() -> AABB:
		assert(radius > 0.0)

		var box = AABB()
		
		box.size = Vector3(radius * 2.0 + 1.0, radius * 2.0 + 1.0, radius * 2.0 + 1.0).ceil()
		box.position = Vector3(location.x - radius, location.y - radius, location.z - radius).floor()
		
		return box


	func get_name() -> String:
		var mode_name: String

		match config.mode:
			VoxelTool.Mode.MODE_ADD:
				mode_name = "add"
			VoxelTool.Mode.MODE_REMOVE:
				mode_name = "remove"
			VoxelTool.Mode.MODE_TEXTURE_PAINT:
				mode_name = "paint"

		return "<%s absolute sphere %f, %f>" % [mode_name, radius, distance]


	func _update_indicator(viewport: Viewport, mode: VoxelTool.Mode):
		_install_indicator_if_needed(viewport)
		_indicator.scale = Vector3(radius * 2.0, radius * 2.0, radius * 2.0)
		_indicator.position = location


	func _install_indicator_if_needed(viewport: Viewport):
		var current_parent = _indicator.get_parent()
	
		if current_parent == viewport:
			return
		
		if current_parent != null:
			current_parent.remove_child(_indicator)

		viewport.add_child(_indicator)


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
