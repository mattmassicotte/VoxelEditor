@tool
class_name SphereSettings
extends Control


signal radius_changed(value: float)


func _ready() -> void:
	_update_label()


var radius: float:
	get:
		return $SizeSlider.value
	set(value):
		$SizeSlider.value = value


func _on_size_value_changed(value: float) -> void:
	radius_changed.emit(value)
	_update_label()


func _update_label() -> void:
	$SizeLabel.text = "%f" % radius
