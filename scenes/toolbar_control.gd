@tool
class_name ToolbarControl
extends Control

signal reset()

var is_target_valid: bool:
	get:
		return target != null and target.node != null
var target: Target: set = set_target
var _brush_settings: BrushSettings
var _brush_panel := PopupPanel.new()
var _operation: Operation
var _texture_panel := PopupPanel.new()
var _texture_settings: TextureSettings
@onready var _brush_button: Button = $BrushButton
@onready var _texture_button: Button = $TextureButton


func _ready() -> void:
	var texture_settings_scene = preload("res://addons/VoxelEditor/settings/texture_settings.tscn")
	_texture_settings = texture_settings_scene.instantiate()
	_texture_settings.scene_file_path = ""
	_texture_settings.reset_pressed.connect(func ():
		_texture_panel.visible = false
		reset.emit()
	)
	_texture_settings.texture_selected.connect(func (index: int):
		if is_target_valid:
			target.tool.texture_index = index
	)
	_texture_settings.texture_falloff_changed.connect(func (value: float):
		if is_target_valid:
			target.tool.texture_falloff = value
	)
	_texture_settings.texture_opacity_changed.connect(func (value: float):
		if is_target_valid:
			target.tool.texture_opacity = value
	)
		
	get_parent().add_child(_texture_panel)
	_texture_panel.add_child(_texture_settings)
	
	var brush_settings_scene = preload("res://addons/VoxelEditor/settings/brush_settings.tscn")
	_brush_settings = brush_settings_scene.instantiate()
	_brush_settings.scene_file_path = ""
	_brush_settings.operation_changed.connect(func (op: Operation):
		if _operation != null:
			_operation.cursor_exited()

		_operation = op
	)
	_brush_settings.sdf_settings_changed.connect(func (strength: float, scale: float):
		if is_target_valid:
			return

		target.tool.sdf_strength = strength
		target.tool.sdf_scale = scale
	)
	
	get_parent().add_child(_brush_panel)
	_brush_panel.add_child(_brush_settings)


func set_target(value: Target) -> void:
	target = value
	visible = is_target_valid
	if is_target_valid:
		target.tool.channel = VoxelBuffer.CHANNEL_SDF
		target.tool.sdf_strength = _brush_settings.sdf_strength
		target.tool.sdf_scale = _brush_settings.sdf_scale
		target.tool.texture_falloff = _texture_settings.texture_falloff
		target.tool.texture_opacity = _texture_settings.texture_opacity
		target.tool.texture_index = 0 # this currently cannot be read
	elif _operation != null:
		_operation.cursor_exited()
		
	_brush_settings.target_updated(target)
	_texture_settings.target_updated(target)


func cursor_location_updated(viewport_camera: Camera3D, apply: bool) -> void:
	if _operation == null:
		return

	_operation.cursor_location_updated(viewport_camera, target, apply)


func _on_texture_button_pressed() -> void:
	var pos = _texture_button.get_screen_transform().origin
	pos.y += _texture_button.size.y

	_texture_panel.set_position(pos)
	_texture_panel.set_size(_texture_settings.get_minimum_size())
	_texture_panel.visible = true


func _on_brush_button_pressed() -> void:
	var pos = _brush_button.get_screen_transform().origin
	pos.y += _brush_button.size.y
	pos.x -= _brush_settings.size.x

	_brush_panel.set_position(pos)
	_brush_panel.set_size(_brush_settings.get_minimum_size())
	_brush_panel.visible = true
