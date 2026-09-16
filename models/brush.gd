@abstract
class_name Brush
extends RefCounted


@abstract
func preview(target: Target, viewport: SubViewport) -> void

@abstract
func activate(target: Target) -> void


@abstract
func deactivate() -> void


func get_settings_node() -> Node:
	return null


class Sphere extends Brush:
	var _indicator: MeshInstance3D
	var _settings: SphereSettings


	var radius: float:
		set(value):
			radius = value
			_indicator.scale = Vector3(value * 2.0, value * 2.0, value * 2.0)


	func _init():
		var indicator_scene = preload("res://addons/VoxelEditor/scenes/indicator.tscn")
		_indicator = indicator_scene.instantiate()
		_indicator.scene_file_path = "" # make local
		
		var settings_scene = preload("res://addons/VoxelEditor/scenes/sphere_settings.tscn")
		_settings = settings_scene.instantiate()
		var welf: WeakRef = weakref(self)
		_settings.radius_changed.connect(func (value):
			welf.get_ref().radius = value
		)
		
		radius = _settings.radius


	func get_settings_node() -> Node:
		return _settings


	func activate(target: Target) -> void:
		target.tool.channel = VoxelBuffer.CHANNEL_SDF
		preview(target, target.node.get_viewport())


	func deactivate() -> void:
		var current_parent = _indicator.get_parent()
		
		if current_parent != null:
			current_parent.remove_child(_indicator)


	func make_operation(target: Target) -> Operation:
		var op: Operation.Sphere
		
		match target.mode:
			Target.Mode.ADD:
				op = Operation.AddSphere.new()
			Target.Mode.REMOVE:
				op = Operation.AddSphere.new()
			Target.Mode.PAINT:
				op = Operation.PaintSphere.new()
				
		op.center = target.location
		op.radius = radius
		
		return op


	func preview(target: Target, viewport: Viewport) -> void:
		_install_indicator_if_needed(viewport)
		_indicator.position = target.location
		
		match target.mode:
			Target.Mode.ADD:
				_indicator.mesh.material.albedo_color = Color(0.1, 0.7, 0.1, 0.3)
			Target.Mode.REMOVE:
				_indicator.mesh.material.albedo_color = Color(0.7, 0.1, 0.1, 0.3)
			Target.Mode.PAINT:
				_indicator.mesh.material.albedo_color = Color(0.1, 0.1, 0.7, 0.3)

	
	func _install_indicator_if_needed(viewport: Viewport):
		var current_parent = _indicator.get_parent()
	
		if current_parent == viewport:
			return
		
		if current_parent != null:
			current_parent.remove_child(_indicator)

		viewport.add_child(_indicator)
