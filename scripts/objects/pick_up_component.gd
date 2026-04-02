class_name PickUpComponent extends Node

signal toggled(is_held: bool)

@export var distance := Vector3(0.2, -0.3, -0.75)
@export var rotation := Vector3.ZERO
@export var margin := 0.2
@export var hide_nodes: Array[Node] = []

@export_group("Scroll Settings")
@export var allow_scroll := true
@export var scroll_step := 0.2
@export var min_scroll_z := -0.75
@export var max_scroll_z := -2.0

@export_group("Rotation Settings")
@export var rotate_key: Key = KEY_V
@export var rotate_speed := 3.0
@export var spin_axis := Vector3.UP
@export var keep_upright := true

@export_group("Inspect Settings")
@export var inspect_position := Vector3(0.0, -0.065, -1.0) 

var held_obj: Node3D
var base_rot: Basis
var current_local_rot: Basis
var ray_query := PhysicsRayQueryParameters3D.new()
var cached_cam: Camera3D

@onready var current_scroll_z := distance.z 
@onready var base_offset := Vector2(distance.x, distance.y)
@onready var base_z := distance.z

func _ready() -> void:
	set_physics_process(false); set_process_input(false)
	base_rot = Basis.from_euler(rotation * 0.01745329)
	var p := get_parent()
	if p.has_signal(&"player_interacted"): p.connect(&"player_interacted", _on_interact)

func _on_interact(target: Node3D) -> void:
	var player := Global.player
	if player and not player.held_object: _toggle(target, true)

func _input(event: InputEvent) -> void: 
	var mb := event as InputEventMouseButton 
	if not mb or not mb.pressed: return
	
	if mb.button_index == MOUSE_BUTTON_RIGHT: _toggle(held_obj, false)
	elif allow_scroll and held_obj:
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP: 
			current_scroll_z = clampf(current_scroll_z - scroll_step, max_scroll_z, min_scroll_z)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN: 
			current_scroll_z = clampf(current_scroll_z + scroll_step, max_scroll_z, min_scroll_z)

func _toggle(target: Node3D, state: bool) -> void:
	var player := Global.player
	held_obj = target if state else null; player.held_object = held_obj
	set_physics_process(state); set_process_input(state)
	
	if target is RigidBody3D: target.freeze = state
	ray_query.exclude = [player.get_rid(), target.get_rid()] if state and target is CollisionObject3D else []
	
	if state:
		current_scroll_z = base_z
		cached_cam = player.camera as Camera3D
		player.add_collision_exception_with(target)
	else:
		player.remove_collision_exception_with(target); cached_cam = null
		
	for n in hide_nodes:
		if is_instance_valid(n):
			n.set(&"visible", not state)
			if &"disabled" in n: n.set_deferred(&"disabled", state)
	toggled.emit(state)

func _physics_process(delta: float) -> void:
	
	var player = Global.player
	var speed = 12.0
	var is_inspecting = false
	
	if player and "is_zooming" in player:
		speed = player.zoom_speed 
		is_inspecting = player.is_zooming
	
	if Input.is_physical_key_pressed(rotate_key):
		is_inspecting = true
		current_local_rot = current_local_rot.rotated((current_local_rot * spin_axis).normalized(), rotate_speed * delta)
		
	if is_inspecting:
		distance.x = lerpf(distance.x, inspect_position.x, speed * delta)
		distance.y = lerpf(distance.y, inspect_position.y, speed * delta)
		distance.z = lerpf(distance.z, inspect_position.z, speed * delta)
	else:
		distance.x = lerpf(distance.x, base_offset.x, speed * delta)
		distance.y = lerpf(distance.y, base_offset.y, speed * delta)
		distance.z = lerpf(distance.z, current_scroll_z, speed * delta)

	var cam_basis := cached_cam.global_basis
	var orig := cached_cam.global_position
	var offset := cam_basis * distance
	var dir := offset.normalized()
	
	ray_query.from = orig; ray_query.to = orig + offset + (dir * margin)
	var hit := held_obj.get_world_3d().direct_space_state.intersect_ray(ray_query)
	var safe_pos := orig + dir * maxf((hit.position as Vector3 - orig).dot(dir) - margin, 0.15) if hit else orig + offset
	
	var ref_basis := cam_basis
	if keep_upright:
		var fwd := -cam_basis.z; fwd.y = 0.0
		ref_basis = Basis.looking_at(fwd.normalized() if fwd.length_squared() > 0.001 else -cam_basis.y, Vector3.UP)
	
	held_obj.global_transform = held_obj.global_transform.interpolate_with(Transform3D(ref_basis * current_local_rot, safe_pos), 0.3)
