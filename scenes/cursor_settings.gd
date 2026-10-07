@tool
class_name CursorSettings
extends Control


signal cursor_distance_changed(distance: float)


var distance: float:
	get:
		return $LineEdit.text.to_float()
	set(value):
		$LineEdit.text = "%.1f" % value
		cursor_distance_changed.emit(value)


func _ready() -> void:
	distance = 10.0


func _on_line_edit_text_changed(new_text: String) -> void:
	var new_distance = new_text.to_float()
	
	assert(new_distance > 0.0)
	
	distance = new_distance
