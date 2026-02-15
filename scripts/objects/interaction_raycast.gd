class_name InteractionRaycast extends RayCast3D

var _target: Node3D = null
var _is_holding: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"):
		_is_holding = true
		_interact(true, false)
	elif event.is_action_released(&"interact"):
		_is_holding = false
		_interact(false, true)
		
func _physics_process(_delta: float) -> void:
	_update_target()
	if _is_holding:
		_interact(false, false)
	elif is_instance_valid(_target) and _target.has_method(&"interact_ui"):
		_target.interact_ui(get_collision_point(), false, false)

func _update_target() -> void:
	var hit: Node3D = get_collider() as Node3D
	var held: Node3D = Global.player.held_object if is_instance_valid(Global.player) else null
	if hit == held: hit = null 
	if hit != _target:
		if is_instance_valid(_target):
			if _is_holding and _target.has_method(&"interact_draw"):
				_target.interact_draw(Vector3.ZERO, false, true)
			if is_instance_valid(held): 
				held.propagate_call(&"cancel_tool", [_target])
			if _target.has_user_signal(&"unfocused"):
				_target.emit_signal(&"unfocused")
		
		_target = hit
		if is_instance_valid(_target) and _target.has_user_signal(&"focused"):
			_target.emit_signal(&"focused")

func _interact(pressed: bool, released: bool) -> void:
	if not is_instance_valid(_target): return
	var held: Node3D = Global.player.held_object if is_instance_valid(Global.player) else null
	var hit_point: Vector3 = get_collision_point() 
	
	if _target.has_method(&"interact_ui"):
		_target.interact_ui(hit_point, pressed, released)
	elif pressed and _target.has_user_signal(&"interacted"):
		_target.emit_signal(&"interacted")
	if is_instance_valid(held): 
		held.propagate_call(&"use_tool", [_target, hit_point, get_collision_normal(), pressed, released])
