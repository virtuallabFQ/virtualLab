class_name PickUpComponent extends Node

@export var distance := Vector3(0, 0, -1.0)
@export var rotation := Vector3.ZERO
@export var margin := 0.2
@export var hide_nodes: Array[Node] = []

@export_group("Scroll Settings")
@export var allow_scroll := true
@export var scroll_step := 0.2
@export var min_scroll_z := -1.0
@export var max_scroll_z := -2.0

var held_obj: Node3D
var base_rot: Basis
var ray_query := PhysicsRayQueryParameters3D.new()
var cached_cam: Camera3D
@onready var default_z := distance.z

func _ready() -> void:
	set_physics_process(false)
	set_process_input(false)
	base_rot = Basis.from_euler(rotation * 0.0174533)
	
	var parent_node := get_parent()
	if parent_node.has_signal(&"player_interacted"):
		parent_node.connect(&"player_interacted", func(target: Node3D):
			var player := Global.player
			if player and not player.held_object: _toggle(target, true)
		)

func _input(event: InputEvent) -> void: 
	if not event is InputEventMouseButton or not event.pressed: return
	
	if event.button_index == MOUSE_BUTTON_RIGHT: 
		_toggle(held_obj, false)
	elif allow_scroll and held_obj:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: distance.z = clampf(distance.z - scroll_step, max_scroll_z, min_scroll_z)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: distance.z = clampf(distance.z + scroll_step, max_scroll_z, min_scroll_z)

func _toggle(target: Node3D, state: bool) -> void:
	var player := Global.player
	held_obj = target if state else null
	player.held_object = held_obj
	set_physics_process(state)
	set_process_input(state)
	
	if target is RigidBody3D: target.freeze = state
	ray_query.exclude = [player.get_rid(), target.get_rid()] if state and target is CollisionObject3D else []
	
	if state:
		distance.z = default_z
		cached_cam = player.camera as Camera3D
		player.add_collision_exception_with(target)
	else:
		cached_cam = null
		player.remove_collision_exception_with(target)
		
	for n in hide_nodes:
		if is_instance_valid(n):
			n.set(&"visible", not state)
			if &"disabled" in n: n.set_deferred(&"disabled", state)

func _physics_process(_delta: float) -> void:
	var orig := cached_cam.global_position
	var offset := cached_cam.global_basis * distance
	var dir := offset.normalized()
	
	ray_query.from = orig
	ray_query.to = orig + offset + (dir * margin)
	
	var hit := held_obj.get_world_3d().direct_space_state.intersect_ray(ray_query)
	var safe_pos := orig + dir * maxf((hit.position as Vector3 - orig).dot(dir) - margin, 0.15) if hit else orig + offset
	held_obj.global_transform = held_obj.global_transform.interpolate_with(Transform3D(cached_cam.global_basis * base_rot, safe_pos), 0.3)
