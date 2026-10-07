@tool
class_name Toolbar
extends Control


@onready var _container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var _brush_button: MenuButton = $MarginContainer/HBoxContainer/BrushMenu
@onready var _mode_button: MenuButton = $MarginContainer/HBoxContainer/ModeMenu


signal tool_changed(mode: Mode, brush: Brush)


enum Mode {
	ADD,
	REMOVE,
	PAINT,
}

enum Brush {
	SPHERE,
}


var mode: Toolbar.Mode = Mode.ADD
var brush: Toolbar.Brush = Brush.SPHERE


func _ready() -> void:
	_brush_button.get_popup().index_pressed.connect(_on_brush_menu_selected)
	_mode_button.get_popup().index_pressed.connect(_on_mode_menu_selected)


func _on_brush_menu_selected(index: int) -> void:
	brush = index
	_brush_button.text = _brush_button.get_popup().get_item_text(index)

	tool_changed.emit(mode, brush)


func _on_mode_menu_selected(index: int) -> void:
	mode = index
	_mode_button.text = _mode_button.get_popup().get_item_text(index)

	tool_changed.emit(mode, brush)


func _install_node(node: Control, in_parent: Control) -> void:
	for child in in_parent.get_children():
		in_parent.remove_child(child)

	in_parent.add_child(node)


func install_cursor_settings(node: Node) -> void:
	var settings_container = $MarginContainer/HBoxContainer/CursorPlaceholder
	
	_install_node(node, settings_container)


func install_brush_settings(node: Node) -> void:
	var settings_container = $MarginContainer/HBoxContainer/BrushPlaceholder
	
	_install_node(node, settings_container)


func install_mode_settings(node: Node) -> void:
	var settings_container = $MarginContainer/HBoxContainer/ModePlaceholder
	
	_install_node(node, settings_container)
