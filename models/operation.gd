@abstract
class_name Operation
extends RefCounted


@abstract
func cursor_location_updated(viewport_camera: Camera3D, target: Target, apply: bool) -> void

@abstract
func cursor_exited() -> void

@abstract
func get_affected_volume() -> AABB


@abstract
func get_name() -> String
