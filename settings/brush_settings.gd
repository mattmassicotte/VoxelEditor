@tool
class_name BrushSettings
extends VBoxContainer

signal operation_changed(op: Operation)
signal sdf_settings_changed(strength: float, scale: float)

var sdf_scale: float:
	get:
		return $SdfSettings/ScaleSlider.value
var sdf_strength: float:
	get:
		return $SdfSettings/StrengthSlider.value
var _absolute_add_box_operation := AbsoluteBoxOperation.new(true)
var _absolute_add_box_settings: Node
var _absolute_add_sphere_operation := AbsoluteSphereOperation.new(true)
var _absolute_add_sphere_settings: Node
var _absolute_remove_box_operation := AbsoluteBoxOperation.new(false)
var _absolute_remove_box_settings: Node
var _absolute_remove_sphere_operation := AbsoluteSphereOperation.new(false)
var _absolute_remove_sphere_settings: Node
var _button_group := ButtonGroup.new()
var _paint_operation := SurfaceSphereOperation.new(SurfaceSphereOperation.Mode.PAINT)
var _paint_settings: Node
var _relative_add_sphere_operation := SurfaceSphereOperation.new(SurfaceSphereOperation.Mode.ADD)
var _relative_sphere_settings: Node
var _surface_remove_sphere_operation := SurfaceSphereOperation.new(SurfaceSphereOperation.Mode.REMOVE)
var _surface_remove_sphere_settings: Node
@onready var subsettings_container: MarginContainer = $MarginContainer
@onready var selection_container: HBoxContainer = $SelectionContainer


func _ready() -> void:
	# assign all brush buttons to the same group
	for child in selection_container.get_children():
		if child is Button:
			child.button_group = _button_group
		
	$SdfSettings/ScaleSlider.value_changed.connect(func (value: float):
		sdf_settings_changed.emit(sdf_strength, value)
	)
	
	$SdfSettings/StrengthSlider.value_changed.connect(func (value: float):
		sdf_settings_changed.emit(value, sdf_scale)
	)

	var abs_sphere_scene = preload("res://addons/VoxelEditor/settings/absolute_sphere_settings.tscn")
	_absolute_add_sphere_settings = abs_sphere_scene.instantiate()
	_absolute_add_sphere_settings.scene_file_path = ""
	
	_take_slider_value(_absolute_add_sphere_settings, _absolute_add_sphere_operation, "RadiusSlider", func (value: float):
		_absolute_add_sphere_operation.radius = value
	)
	_take_slider_value(_absolute_add_sphere_settings, _absolute_add_sphere_operation, "DistanceSlider", func (value: float):
		_absolute_add_sphere_operation.distance = value
	)
	
	_absolute_remove_sphere_settings = abs_sphere_scene.instantiate()
	_absolute_remove_sphere_settings.scene_file_path = ""
	
	_take_slider_value(_absolute_remove_sphere_settings, _absolute_remove_sphere_operation, "RadiusSlider", func (value: float):
		_absolute_remove_sphere_operation.radius = value
	)
	_take_slider_value(_absolute_remove_sphere_settings, _absolute_remove_sphere_operation, "DistanceSlider", func (value: float):
		_absolute_remove_sphere_operation.distance = value
	)
	
	var abs_box_scene = preload("res://addons/VoxelEditor/settings/absolute_box_settings.tscn")
	_absolute_add_box_settings = abs_box_scene.instantiate()
	_absolute_add_box_settings.scene_file_path = ""
	
	_take_slider_value(_absolute_add_box_settings, _absolute_add_box_operation, "DistanceSlider", func (value: float):
		_absolute_add_box_operation.distance = value
	)
	_take_slider_value(_absolute_add_box_settings, _absolute_add_box_operation, "LengthSlider", func (value: float):
		_absolute_add_box_operation.length = value
	)
	_take_slider_value(_absolute_add_box_settings, _absolute_add_box_operation, "WidthSlider", func (value: float):
		_absolute_add_box_operation.width = value
	)
	_take_slider_value(_absolute_add_box_settings, _absolute_add_box_operation, "HeightSlider", func (value: float):
		_absolute_add_box_operation.height = value
	)
	
	_absolute_remove_box_settings = abs_box_scene.instantiate()
	_absolute_remove_box_settings.scene_file_path = ""
	
	_take_slider_value(_absolute_remove_box_settings, _absolute_remove_box_operation, "DistanceSlider", func (value: float):
		_absolute_remove_box_operation.distance = value
	)
	_take_slider_value(_absolute_remove_box_settings, _absolute_remove_box_operation, "LengthSlider", func (value: float):
		_absolute_remove_box_operation.length = value
	)
	_take_slider_value(_absolute_remove_box_settings, _absolute_remove_box_operation, "WidthSlider", func (value: float):
		_absolute_remove_box_operation.width = value
	)
	_take_slider_value(_absolute_remove_box_settings, _absolute_remove_box_operation, "HeightSlider", func (value: float):
		_absolute_remove_box_operation.height = value
	)
	
	var relative_sphere_scene = preload("res://addons/VoxelEditor/settings/sphere_settings.tscn")
	_relative_sphere_settings = relative_sphere_scene.instantiate()
	_relative_sphere_settings.scene_file_path = ""
	
	_take_slider_value(_relative_sphere_settings, _relative_add_sphere_operation, "RadiusSlider", func (value: float):
		_relative_add_sphere_operation.radius = value
	)
	
	_surface_remove_sphere_settings = relative_sphere_scene.instantiate()
	_surface_remove_sphere_settings.scene_file_path = ""
	
	_take_slider_value(_surface_remove_sphere_settings, _surface_remove_sphere_operation, "RadiusSlider", func (value: float):
		_surface_remove_sphere_operation.radius = value
	)
	
	var paint_settings_scene = preload("res://addons/VoxelEditor/settings/paint_settings.tscn")
	_paint_settings = paint_settings_scene.instantiate()
	_paint_settings.scene_file_path = ""
	
	_take_slider_value(_paint_settings, _paint_operation, "RadiusSlider", func (value: float):
		_paint_operation.radius = value
	)

	# this simulates the first brush being selected
	var first_button: BaseButton = _button_group.get_buttons().front()
	first_button.set_pressed(true)
	first_button.pressed.emit()


func target_updated(target: Target) -> void:
	pass


func _install_settings(node: Node) -> void:
	for child in subsettings_container.get_children():
		subsettings_container.remove_child(child)

	if node != null:
		subsettings_container.add_child(node)


func _take_slider_value(node: Node, op: Operation, name: String, on_set: Callable) -> void:
	var slider: LabelledSlider = node.find_child(name)
	
	on_set.call(node.find_child(name).value)

	slider.value_changed.connect(func (value: float):
		on_set.call(node.find_child(name).value)

		operation_changed.emit(op)
	)


func _on_absolute_sphere_add_button_pressed() -> void:
	_install_settings(_absolute_add_sphere_settings)
	operation_changed.emit(_absolute_add_sphere_operation)


func _on_absolute_sphere_remove_button_pressed() -> void:
	_install_settings(_absolute_remove_sphere_settings)
	operation_changed.emit(_absolute_remove_sphere_operation)


func _on_absolute_box_add_button_pressed() -> void:
	_install_settings(_absolute_add_box_settings)
	operation_changed.emit(_absolute_add_box_operation)


func _on_paint_button_pressed() -> void:
	_install_settings(_paint_settings)
	operation_changed.emit(_paint_operation)


func _on_sphere_add_button_pressed() -> void:
	_install_settings(_relative_sphere_settings)
	operation_changed.emit(_relative_add_sphere_operation)


func _on_sphere_remove_button_pressed() -> void:
	_install_settings(_surface_remove_sphere_settings)
	operation_changed.emit(_surface_remove_sphere_operation)


func _on_absolute_box_remove_button_pressed() -> void:
	_install_settings(_absolute_remove_box_settings)
	operation_changed.emit(_absolute_remove_box_operation)
