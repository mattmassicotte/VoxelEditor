@tool
class_name TextureSettings
extends VBoxContainer

signal reset_pressed

@onready var _texture_grid: GridContainer = $TextureGrid

func _ready() -> void:
	for i in range(16):
		var entry = _make_texture_child()
		
		entry.gui_input.connect(_on_rect_gui_input.bind(i))
		_texture_grid.add_child(entry)


func _make_texture_child() -> Node:
	# I guess this could be a scene?
	var rect := TextureRect.new()
	rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH

	var margin = MarginContainer.new()

	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_left", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	margin.add_theme_constant_override("margin_right", 2)

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
		var rect: TextureRect = _texture_grid.get_child(i).get_child(0).get_child(0)
		
		rect.texture = ImageTexture.create_from_image(image)


func _on_reload_button_pressed() -> void:
	reset_pressed.emit()


func _on_rect_gui_input(event: InputEvent, index: int) -> void:
	print("event: ", index)
