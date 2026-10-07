@abstract
class_name EditMode
extends RefCounted


class ModifyMatterMode extends EditMode:

	var scale: float
	var strength: float


class AddMode extends ModifyMatterMode:
	pass


class RemoveMode extends ModifyMatterMode:
	pass


class PaintMode extends EditMode:

	var index: int
	var falloff: float
	var opacity: float
