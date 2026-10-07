@tool
class_name PaintSettings
extends HBoxContainer


@onready var _list: HBoxContainer = $TextureContainer


signal texture_selected(int)


func target_updated(target: Target) -> void:
	# we might not yet be installed in the tree
	if _list == null:
		return

	for child in _list.get_children():
		_list.remove_child(child)

	if target.node is VoxelLodTerrain == false:
		return

	var shader_material := target.node.material as ShaderMaterial
	if shader_material == null:
		print("expected a ShaderMaterial")
		return

	var layered := shader_material.get_shader_parameter("u_albedo_array") as TextureLayered
	if layered == null:
		print("expected a TextureLayered")
		return
	
	var count := layered.get_layers()
	for i in range(count):
		var image := layered.get_layer_data(i)

		var rect := TextureRect.new()
		rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		rect.texture = ImageTexture.create_from_image(image)
		rect.gui_input.connect(_on_rect_gui_input.bind(i))
		
		var margin = MarginContainer.new()

		margin.add_theme_constant_override("margin_top", 1)
		margin.add_theme_constant_override("margin_left", 2)
		margin.add_theme_constant_override("margin_bottom", 1)
		margin.add_theme_constant_override("margin_right", 2)

		margin.add_child(rect)
		margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		var background = ColorRect.new()
		
		background.color = Color.WHITE
		background.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		background.add_child(margin)
		
		_list.add_child(background)


func _on_rect_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton == false:
		return
	
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.is_pressed() == false:
		return

	for child: ColorRect in _list.get_children():
		child.color = Color.TRANSPARENT

	_list.get_child(index).color = Color.WHITE
	
	texture_selected.emit(index)
	
