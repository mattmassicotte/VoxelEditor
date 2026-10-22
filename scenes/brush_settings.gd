@tool
class_name BrushSettings
extends VBoxContainer

var _absolute_box_settings: Node
var _absolute_sphere_settings: Node
var _button_group := ButtonGroup.new()
@onready var subsettings_container: MarginContainer = $MarginContainer
@onready var selection_container: HBoxContainer = $SelectionContainer


func _ready() -> void:
	for child in selection_container.get_children():
		if child is Button:
			child.button_group = _button_group

	var abs_sphere_scene = preload("res://addons/VoxelEditor/scenes/absolute_sphere_settings.tscn")
	_absolute_sphere_settings = abs_sphere_scene.instantiate()
	_absolute_sphere_settings.scene_file_path = ""
	_absolute_sphere_settings.find_child("RadiusSlider").value_changed.connect(func (value: float):
		print("radius: ", value)
	)
	
	var abs_box_scene = preload("res://addons/VoxelEditor/settings/absolute_box_settings.tscn")
	_absolute_box_settings = abs_box_scene.instantiate()
	_absolute_box_settings.scene_file_path = ""
	_absolute_box_settings.find_child("LengthSlider").value_changed.connect(func (value: float):
		print("length: ", value)
	)
	_absolute_box_settings.find_child("WidthSlider").value_changed.connect(func (value: float):
		print("width: ", value)
	)
	_absolute_box_settings.find_child("HeightSlider").value_changed.connect(func (value: float):
		print("height: ", value)
	)
	
	var first_button: BaseButton = _button_group.get_buttons().front()
	first_button.set_pressed(true)
	first_button.pressed.emit()


func target_updated(target: Target) -> void:
	pass


func _install_settings(node: Node) -> void:
	for child in subsettings_container.get_children():
		subsettings_container.remove_child(child)

	subsettings_container.add_child(node)


func _on_absolute_sphere_add_button_pressed() -> void:
	_install_settings(_absolute_sphere_settings)


func _on_absolute_box_add_button_pressed() -> void:
	_install_settings(_absolute_box_settings)
