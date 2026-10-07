class_name ToolConfiguration
extends RefCounted

var mode: VoxelTool.Mode
var texture_index: int = 0
var texture_falloff: float = 0.5
var texture_opacity: float = 1.0
var sdf_strength: float = 1.0
var sdf_scale: float = 1.0
	
	
func apply(tool: VoxelTool) -> void:
	tool.channel = VoxelBuffer.CHANNEL_SDF
	tool.mode = mode
	tool.texture_index = texture_index
	tool.texture_falloff = texture_falloff
	tool.texture_opacity = texture_opacity
	tool.sdf_strength = sdf_strength
	tool.sdf_scale = sdf_scale
	
	print(texture_index)


func copy() -> ToolConfiguration:
	var config := ToolConfiguration.new()

	config.mode = mode
	config.texture_index = texture_index
	config.texture_falloff = texture_falloff
	config.texture_opacity = texture_opacity
	config.sdf_strength = sdf_strength
	config.sdf_scale = sdf_scale

	return config
