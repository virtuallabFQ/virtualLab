class_name EraseComponent extends Node

@export var distance := Vector3(0, 0, -1.0) 
@export var margin := 0.2 
@export var hide_nodes: Array[Node] = []
@export var erase_range := 0.8 
@export_enum("-Z","Z","-Y","Y","-X","X") var facing := 1

var held: Node3D
var fixed_z := 0.0
var fixed_basis: Basis
var was_erasing := false
var last_col: Node3D
var ray_q := PhysicsRayQueryParameters3D.new()
var erase_q := PhysicsRayQueryParameters3D.new()

func _ready() -> void:
	set_physics_process(false); set_process_input(false)
	get_parent().connect(&"player_interacted", func(t): if not held and Global.player: _toggle(t, true))

func _input(event: InputEvent) -> void: 
	if event is InputEventMouseButton and event.button_index == 2 and event.pressed: _toggle(held, false)

func _toggle(target: Node3D, state: bool) -> void:
	held = target if state else null; Global.player.held_object = held
	set_physics_process(state); set_process_input(state); ray_q.exclude = []; erase_q.exclude = []
	if target is RigidBody3D: target.freeze = state
	for n in hide_nodes: if is_instance_valid(n): n.set(&"visible", not state); if "disabled" in n: n.set_deferred(&"disabled", state)
	if not state:
		Global.player.remove_collision_exception_with(target)
		if was_erasing and last_col: last_col.interact_erase(Vector3.ZERO, false, true)
		was_erasing = false; last_col = null; return
	fixed_z = target.global_position.z; fixed_basis = target.global_basis; Global.player.add_collision_exception_with(target)
	ray_q.exclude = [Global.player.get_rid(), target.get_rid()]; erase_q.exclude = ray_q.exclude

func _physics_process(_d: float) -> void:
	var cam := Global.player.camera as Camera3D; var orig := cam.global_position; var dir := (cam.global_basis * distance)
	ray_q.from = orig; ray_q.to = orig + dir + (dir.normalized() * margin)
	var space := held.get_world_3d().direct_space_state; var hit := space.intersect_ray(ray_q)
	
	var safe_pos: Vector3 = orig + dir.normalized() * max(orig.distance_to(hit.position as Vector3) - margin, 0.15) if hit else orig + dir
	safe_pos.z = fixed_z; held.global_transform = held.global_transform.interpolate_with(Transform3D(fixed_basis, safe_pos), 0.3)
	
	var dirs := [Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP, Vector3.LEFT, Vector3.RIGHT]
	erase_q.from = held.global_position; erase_q.to = held.global_position + (held.global_basis * dirs[facing] * erase_range)
	var e_hit := space.intersect_ray(erase_q)
	
	if e_hit and e_hit.collider.has_method(&"interact_erase"):
		e_hit.collider.interact_erase(e_hit.position as Vector3, not was_erasing, false); was_erasing = true; last_col = e_hit.collider
	elif was_erasing:
		if last_col: last_col.interact_erase(Vector3.ZERO, false, true)
		was_erasing = false; last_col = null
