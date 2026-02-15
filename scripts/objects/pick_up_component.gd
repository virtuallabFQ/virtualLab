class_name PickUpComponent extends Node

@export var distance: Vector3 = Vector3(0, 0, -1.0)
@export var rotation: Vector3 = Vector3.ZERO
@export var margin: float = 0.2
@export var hide_nodes: Array[Node] = []

var held_obj: Node3D
var base_rot: Basis
var ray_query := PhysicsRayQueryParameters3D.new()
var cached_cam: Camera3D

func _ready() -> void:
	set_physics_process(false) 
	set_process_input(false)
	base_rot = Basis.from_euler(rotation * (PI / 180.0))
	var parent_node := get_parent()
	if parent_node.has_signal(&"player_interacted"):
		parent_node.connect(&"player_interacted", func(target): if not held_obj and Global.player: _toggle(target, true))

func _input(event: InputEvent) -> void: 
	if event is InputEventMouseButton and event.button_index == 2 and event.pressed: _toggle(held_obj, false)

func _toggle(target: Node3D, state: bool) -> void:
	held_obj = target if state else null
	Global.player.held_object = held_obj
	set_physics_process(state); set_process_input(state)
	
	if state:
		cached_cam = Global.player.camera as Camera3D
		Global.player.add_collision_exception_with(target)
	else:
		cached_cam = null
		Global.player.remove_collision_exception_with(target)
	
	if target is RigidBody3D: target.freeze = state
	ray_query.exclude = [Global.player.get_rid(), target.get_rid()] if state and target is CollisionObject3D else []
	
	for n in hide_nodes:
		if is_instance_valid(n): n.set(&"visible", not state); if "disabled" in n: n.set_deferred(&"disabled", state)

func _physics_process(_delta: float) -> void:
	var orig: Vector3 = cached_cam.global_position
	var offset: Vector3 = cached_cam.global_basis * distance 
	var t_pos: Vector3 = orig + offset
	var dir: Vector3 = offset.normalized()
	
	ray_query.from = orig; ray_query.to = t_pos + (dir * margin)
	var hit: Dictionary = held_obj.get_world_3d().direct_space_state.intersect_ray(ray_query)
	var safe_pos: Vector3 = orig + dir * max(orig.distance_to(hit.position) - margin, 0.15) if hit else t_pos
	held_obj.global_transform = held_obj.global_transform.interpolate_with(Transform3D(cached_cam.global_basis * base_rot, safe_pos), 0.3)
