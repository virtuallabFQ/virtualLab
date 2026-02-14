class_name EraseComponent extends Node

var is_erasing : bool = false
var snap_pos : Vector3 = Vector3.ZERO
var snap_normal : Vector3 = Vector3.UP

func _ready() -> void:
	process_priority = 1

func use_tool(target: Node3D, pos: Vector3, normal: Vector3, is_just_pressed: bool, is_released: bool):
	if target.has_method("interact_erase"):
		target.interact_erase(pos, is_just_pressed, is_released)
		
	if is_released:
		stop_erasing()
	else:
		is_erasing = true
		snap_pos = pos
		snap_normal = normal

func cancel_tool(target: Node3D = null):
	if target and target.has_method("interact_erase"):
		target.interact_erase(Vector3.ZERO, false, true)
	stop_erasing()

func stop_erasing():
	is_erasing = false

func _physics_process(_delta: float):
	if is_erasing and Global.player:
		var object = get_parent() as Node3D
		if not object: return
		if Global.player.held_object != object:
			stop_erasing()
			return
			
		var final_target = object.global_transform
		final_target.origin = snap_pos + (snap_normal * 0.05)
		object.global_transform = object.global_transform.interpolate_with(final_target, 1.0)
