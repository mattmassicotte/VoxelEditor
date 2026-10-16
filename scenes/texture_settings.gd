@tool
class_name TextureSettings
extends VBoxContainer

signal reset_pressed
signal texture_selected(int)
signal texture_opacity_changed(float)
signal texture_falloff_changed(float)

var texture_opacity: float:
	get:
		return $OpacityContainer/Slider.value
	set(value):
		$OpacityContainer/Slider.value = value

var texture_falloff: float:
	get:
		return $FalloffContainer/Slider.value
	set(value):
		$FalloffContainer/Slider.value = value

@onready var _texture_grid: GridContainer = $TextureGrid


func _ready() -> void:
	for i in range(16):
		var entry = _make_texture_child()
		
		entry.gui_input.connect(_on_rect_gui_input.bind(i))
		_texture_grid.add_child(entry)

	# select the first entry by default
	_get_grid_background(0).color = Color.WHITE


func _make_texture_child() -> Node:
	# I guess this could be a scene?
	var rect := TextureRect.new()
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH

	var margin = MarginContainer.new()

	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.add_theme_constant_override("margin_right", 4)

	margin.add_child(rect)
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		
	var background = ColorRect.new()
		
	background.color = Color.TRANSPARENT
	background.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	background.size_flags_vertical = Control.SIZE_EXPAND_FILL
	background.custom_minimum_size = Vector2i(20,20)
		
	background.add_child(margin)
		
	return background
	

func target_updated(target: Target) -> void:
	var layered = target.get_terrain_textures()

	_populate_texture_grid(layered)


func _populate_texture_grid(layered: TextureLayered) -> void:
	if layered == null:
		return
	
	var count := layered.get_layers()
	assert(count <= 16)

	for i in range(count):
		var image := layered.get_layer_data(i)
		var texture = ImageTexture.create_from_image(image)
		var rect: TextureRect = _get_texture_rect(i)
		
		rect.texture = ImageTexture.create_from_image(image)


func _get_texture_rect(index: int) -> TextureRect:
	return _get_grid_background(index).get_child(0).get_child(0)


func _get_grid_background(index: int) -> ColorRect:
	return _texture_grid.get_child(index)


func _update_opacity_label() -> void:
	$OpacityContainer/ValueLabel.text = "%.2f" % texture_opacity


func _update_falloff_label() -> void:
	$FalloffContainer/ValueLabel.text = "%.2f" % texture_falloff


func _on_reload_button_pressed() -> void:
	reset_pressed.emit()


func _on_rect_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton == false:
		return
	
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.is_pressed() == false:
		return
	
	for i in range(_texture_grid.get_children().size()):
		_get_grid_background(i).color = Color.TRANSPARENT

	_get_grid_background(index).color = Color.WHITE
	
	texture_selected.emit(index)


func _on_falloff_slider_value_changed(value: float) -> void:
	_update_falloff_label()
	texture_falloff_changed.emit(value)


func _on_opacity_slider_value_changed(value: float) -> void:
	_update_opacity_label()
	texture_opacity_changed.emit(value)
