class_name MarkerComponent extends Node

func use_tool(target: Node3D, pos: Vector3, _normal: Vector3, is_just_pressed: bool, is_released: bool):
	if target.has_method("interact_draw"):
		target.interact_draw(pos, is_just_pressed, is_released)

func cancel_tool(target: Node3D = null):
	if target and target.has_method("interact_draw"):
		target.interact_draw(Vector3.ZERO, false, true)
