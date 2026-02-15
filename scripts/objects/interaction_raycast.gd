class_name InteractionRaycast extends RayCast3D

var target: Node3D
var is_holding := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"): 
		is_holding = true
		_interact(true, false)
	elif event.is_action_released(&"interact"): 
		is_holding = false
		_interact(false, true)

func _physics_process(_delta: float) -> void:
	var held: Node3D = Global.player.held_object if Global.player else null
	var hit := get_collider() as Node3D; if hit == held: hit = null
	
	if hit != target:
		if target:
			if is_holding and target.has_method(&"interact_draw"): target.interact_draw(Vector3.ZERO, false, true)
			if held: held.propagate_call(&"cancel_tool", [target])
			if target.has_user_signal(&"unfocused"): target.emit_signal(&"unfocused")
			MessageBus.interaction_unfocused.emit()
		target = hit; if target and target.has_user_signal(&"focused"): target.emit_signal(&"focused")

	var hit_pt := get_collision_point() if target else Vector3.ZERO
	if is_holding: _interact_process(held, hit_pt)
	elif target and target.has_method(&"interact_ui"): target.interact_ui(hit_pt, false, false)

func _interact(pressed: bool, released: bool) -> void:
	var held: Node3D = Global.player.held_object if Global.player else null
	_interact_action(held, get_collision_point() if target else Vector3.ZERO, pressed, released)

func _interact_process(held: Node3D, hit_pt: Vector3) -> void:
	_interact_action(held, hit_pt, false, false)

func _interact_action(held: Node3D, hit_pt: Vector3, pressed: bool, released: bool) -> void:
	if not target: return
	if target.has_method(&"interact_ui"): target.interact_ui(hit_pt, pressed, released)
	elif pressed and target.has_user_signal(&"interacted"): target.emit_signal(&"interacted")
	if held: held.propagate_call(&"use_tool", [target, hit_pt, get_collision_normal(), pressed, released])
