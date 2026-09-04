@abstract
class_name Tool
extends RefCounted


@abstract
func make_operation(target: Target) -> Operation


@abstract
func preview(target: Target, viewport: SubViewport) -> void


@abstract
func activate(target: Target) -> void


@abstract
func deactivate() -> void


func get_settings_node() -> Node:
	return null


var action_name: String:
	get:
		return "<none>"


class Sphere extends Tool:
	var _indicator: MeshInstance3D
	var _settings: SphereSettings


	var radius: float:
		set(value):
			radius = value
			_indicator.scale = Vector3(value * 2.0, value * 2.0, value * 2.0)


	var additive: bool:
		set(value):
			additive = value
			_indicator.mesh.material.albedo_color = _color_for_mode()


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
		additive = true

		
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
		var op = Operation.Sphere.new()
		
		op.center = target.location
		op.radius = radius
		op.additive = additive
		
		return op


	func preview(target: Target, viewport: Viewport) -> void:
		_install_indicator_if_needed(viewport)
		_indicator.position = target.location

	
	func _color_for_mode() -> Color:
		if additive:
			return Color(0.1, 0.7, 0.1, 0.3)
		else:
			return Color(0.7, 0.1, 0.1, 0.3)
	
	
	func _install_indicator_if_needed(viewport: Viewport):
		var current_parent = _indicator.get_parent()
	
		if current_parent == viewport:
			return
		
		if current_parent != null:
			current_parent.remove_child(_indicator)

		viewport.add_child(_indicator)
