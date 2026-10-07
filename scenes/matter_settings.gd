@tool
class_name MatterSettings
extends HBoxContainer


signal matter_settings_changed(strength: float, scale: float)


var sdf_scale: float:
	get:
		return $ScaleSlider.value
	set(value):
		$ScaleSlider.value = value


var sdf_strength: float:
	get:
		return $StrengthSlider.value
	set(value):
		$StrengthSlider.value = value


func _ready() -> void:
	_update_strength_label()
	_update_strength_label()
	
func _on_strength_slider_value_changed(value: float) -> void:
	matter_settings_changed.emit(value, sdf_scale)
	_update_strength_label()


func _on_scale_slider_value_changed(value: float) -> void:
	matter_settings_changed.emit(sdf_strength, value)
	_update_strength_label()


func _update_strength_label() -> void:
	$StrengthText.text = "%.1f" % sdf_strength
	

func _update_scale_label() -> void:
	$ScaleText.text = "%.1f" % sdf_scale
