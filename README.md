# VoxelEditor

A Godot editor plugin for working with voxels.

I made this primarily to experiment with in-editor level building. It would never have been possible without [godot_voxel](https://github.com/Zylann/godot_voxel) and I'm deeply appreciative for that project. If you find this useful, I'd love for you to support that project in whatever way you can.

## Features

- Absolute and surface-based targeting
- Spherical, box brushes, and texture painting
- Texture palette
- Undo support

![Example screenshot](example.png)

## Integration

- First, make sure you have Voxel Tools installed and working
- Drop this into your `/addons` directory
- Enable the plugin with Project > Project Settings > Plugins
- Select a `VoxelTerrain` node in the spacial editor
- Ensure that **both** "Editor View Follow Camera" **and** "Enable Editor Viewer" are enabled for your terrain node

## Texturing

Getting texturing working is not very straightforward. This is an area I'd really like to improve, so if you have ideas, please send them my way!

- Ensure your mesher is `VoxelMesherTransvoxel`
- Set the mesher's texturing mode to `Mixel4`
- Assign a new `ShaderMaterial` to the terrain
- Use the "mixel4_array.gdshader" shader for that material, which comes from this plugin
- Assign its "U Albedo Array" to a texture array with your textures (max of 16)

The in-editor texture palette currently needs to read shader data. So if you use an alternative system it must have an identical structure or the texturing palette will not work.

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
