@tool
class_name Toolbar
extends Control


signal item_selected(kind: ItemKind)


enum ItemKind {
	ADD,
	REMOVE,
}

func _ready() -> void:
	pass


func _on_add_button_pressed() -> void:
	item_selected.emit(ItemKind.ADD)


func _on_remove_button_pressed() -> void:
	item_selected.emit(ItemKind.REMOVE)
