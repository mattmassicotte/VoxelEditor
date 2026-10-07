@abstract
class_name Brush
extends RefCounted


@abstract
func preview(target: Target, mode: Toolbar.Mode, viewport: SubViewport) -> void

@abstract
func activate(target: Target, mode: Toolbar.Mode) -> void


@abstract
func deactivate() -> void


class Sphere extends Brush:
	var _indicator: MeshInstance3D


	func set_radius(radius: float):
		_indicator.scale = Vector3(radius * 2.0, radius * 2.0, radius * 2.0)


	func _init():
		var indicator_scene = preload("res://addons/VoxelEditor/scenes/indicator.tscn")
		_indicator = indicator_scene.instantiate()
		_indicator.scene_file_path = "" # make local


	func activate(target: Target, mode: Toolbar.Mode) -> void:
		preview(target, mode, target.node.get_viewport())


	func deactivate() -> void:
		var current_parent = _indicator.get_parent()
		
		if current_parent != null:
			current_parent.remove_child(_indicator)


	#func make_operation(target: Target) -> Operation:
		#var op: Operation.Sphere
		#
		#match target.mode:
			#Target.Mode.ADD:
				#op = Operation.AddSphere.new()
			#Target.Mode.REMOVE:
				#op = Operation.AddSphere.new()
			#Target.Mode.PAINT:
				#op = Operation.PaintSphere.new()
				#
		#op.center = target.location
		#op.radius = radius
		#
		#return op


	func preview(target: Target, mode: Toolbar.Mode, viewport: Viewport) -> void:
		_install_indicator_if_needed(viewport)
		_indicator.position = target.location
		
		match mode:
			Toolbar.Mode.ADD:
				_indicator.mesh.material.albedo_color = Color(0.1, 0.7, 0.1, 0.3)
			Toolbar.Mode.REMOVE:
				_indicator.mesh.material.albedo_color = Color(0.7, 0.1, 0.1, 0.3)
			Toolbar.Mode.PAINT:
				_indicator.mesh.material.albedo_color = Color(0.1, 0.1, 0.7, 0.3)

	
	func _install_indicator_if_needed(viewport: Viewport):
		var current_parent = _indicator.get_parent()
	
		if current_parent == viewport:
			return
		
		if current_parent != null:
			current_parent.remove_child(_indicator)

		viewport.add_child(_indicator)
