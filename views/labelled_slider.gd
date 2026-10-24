@tool
class_name LabelledSlider
extends HBoxContainer

signal value_changed(float)

@export var label: String:
	get:
		return $Label.text
	set(val):
		$Label.text = val

@export var min_horizontal_label_size: float:
	get:
		return $Label.custom_minimum_size.x
	set(val):
		var existing = $Label.custom_minimum_size
		existing.x = val
		$Label.custom_minimum_size = existing

@export var max_value: float:
	get:
		return $HSlider.max_value
	set(val):
		$HSlider.max_value = val

@export var min_value: float:
	get:
		return $HSlider.min_value
	set(val):
		$HSlider.min_value = val

@export var value: float:
	get:
		return $HSlider.value
	set(value):
		$HSlider.value = value


func _ready() -> void:
	_update_value_label()


func _update_value_label() -> void:
	$ValueLabel.text = "%.2f" % value


func _on_slider_value_changed(value: float) -> void:
	_update_value_label()
	value_changed.emit(value)
