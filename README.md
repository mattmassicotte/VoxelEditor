# VoxelEditor

A Godot editor plugin for working with [godot_voxel](https://github.com/Zylann/godot_voxel)

## Features

Currently, **very** limited.

- Add/Subtract from a `VoxelLodTerrain`
- Texture Painting
- Spherical Brushes
- Target visualization
- Undo Support

![Example screenshot](example.png)

## Integration

- First, make sure you have Voxel Tools installed and working
- Drop this into your `/addons` directory
- Enable the plugin with Project > Project Settings > Plugins
- Select a `VoxelTerrain` node in the spacial editor

Right now, the texture painting tool is only a proof-of-concept. It "works" with a mesher in mixel4 texturing mode, but there's currently no way to control any of the tool parameters.

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
