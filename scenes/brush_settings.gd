@tool
class_name BrushSettings
extends VBoxContainer

var _button_group := ButtonGroup.new()
@onready var selection_container: HBoxContainer = $SelectionContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in selection_container.get_children():
		if child is Button:
			child.button_group = _button_group


func _on_absolute_sphere_add_button_pressed() -> void:
	print("abs sphere add")


func _on_absolute_box_add_button_pressed() -> void:
	print("abs box add")
