@tool
class_name ToolbarControl
extends Control

signal reset()

var _current_operation: Operation
var _panel := PopupPanel.new()
@onready var _texture_button: Button = $TextureButton
var _texture_settings: TextureSettings


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().add_child(_panel)

	var texture_settings_scene = preload("res://addons/VoxelEditor/scenes/texture_settings.tscn")
	_texture_settings = texture_settings_scene.instantiate()
	_texture_settings.scene_file_path = ""
	_texture_settings.reset_pressed.connect(func ():
		_panel.visible = false
		reset.emit()
	)
	_texture_settings.texture_selected.connect(func (index: int):
		if _current_operation != null:
			_current_operation.config.texture_index = index
	)
	_texture_settings.texture_falloff_changed.connect(func (value: float):
		if _current_operation != null:
			_current_operation.config.texture_falloff = value
	)
	_texture_settings.texture_opacity_changed.connect(func (value: float):
		if _current_operation != null:
			_current_operation.config.texture_opacity = value
	)
	
	_panel.add_child(_texture_settings)


func target_updated(target: Target) -> void:
	visible = target.node != null
	_texture_settings.target_updated(target)


func _on_texture_button_pressed() -> void:
	var pos = _texture_button.get_screen_transform().origin
	pos.y += _texture_button.size.y

	_panel.set_position(pos)
	_panel.set_size(_texture_settings.get_minimum_size())
	_panel.visible = true
