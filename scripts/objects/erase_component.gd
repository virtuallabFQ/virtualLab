class_name EraseComponent extends Node

const DIRS: Array[Vector3] = [Vector3.FORWARD, Vector3.BACK, Vector3.DOWN, Vector3.UP, Vector3.LEFT, Vector3.RIGHT]
@export var distance := Vector3(0, 0, -1.0)
@export var margin := 0.2
@export var erase_range := 0.8
@export var drop_distance := 2.0 
@export_enum("-Z","Z","-Y","Y","-X","X") var facing := 1

var held: Node3D
var last_collider: Node3D
var cached_cam: Camera3D
var fixed_z := 0.0
var fixed_basis: Basis
var was_erasing := false

var ray_query := PhysicsRayQueryParameters3D.new()
var erase_query := PhysicsRayQueryParameters3D.new()

var extents := Vector2.ZERO
var erase_vector := Vector3.ZERO

@onready var drop_distance_sq := drop_distance * drop_distance

func _ready() -> void:
	set_physics_process(false); set_process_input(false)
	if get_parent().has_signal(&"player_interacted"): get_parent().connect(&"player_interacted", func(target: Node3D): if Global.player and not Global.player.held_object: _toggle(target, true))

func _input(event: InputEvent) -> void: 
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT: _toggle(held, false)

func _toggle(target: Node3D, state: bool) -> void:
	var player := Global.player; held = target if state else null; player.held_object = held
	set_physics_process(state); set_process_input(state)
	if target is RigidBody3D: target.freeze = state
	ray_query.exclude = [player.get_rid(), target.get_rid()] if state and target is CollisionObject3D else []; erase_query.exclude = ray_query.exclude
	
	if not state:
		cached_cam = null; player.remove_collision_exception_with(target)
		if was_erasing and is_instance_valid(last_collider): last_collider.interact_erase(Vector3.ZERO, false, true)
		was_erasing = false; last_collider = null; return

	fixed_z = target.global_position.z; fixed_basis = target.global_basis; erase_vector = fixed_basis * DIRS[facing] * erase_range
	cached_cam = player.camera as Camera3D; player.add_collision_exception_with(target)
	
	var meshes := target.find_children("*", "MeshInstance3D", true, false)
	if not meshes.is_empty(): var mesh_node := meshes[0] as MeshInstance3D; var aabb_size := mesh_node.get_aabb().size * mesh_node.global_transform.basis.get_scale(); extents = Vector2(aabb_size.x, aabb_size.y) * 0.5
	else: extents = Vector2(0.1, 0.1)

func _physics_process(_delta: float) -> void:
	var orig := cached_cam.global_position
	if orig.distance_squared_to(held.global_position) > drop_distance_sq: return _toggle(held, false)

	var offset := cached_cam.global_basis * distance; var dir := offset.normalized()
	ray_query.from = orig; ray_query.to = orig + offset + (dir * margin)
	var space := held.get_world_3d().direct_space_state; var hit := space.intersect_ray(ray_query)
	var safe_pos := orig + dir * maxf((hit.position as Vector3 - orig).dot(dir) - margin, 0.15) if hit else orig + offset
	
	if was_erasing and is_instance_valid(last_collider) and last_collider.has_method(&"clamp_position"): safe_pos = last_collider.clamp_position(safe_pos, extents)
	safe_pos.z = fixed_z; held.global_transform = held.global_transform.interpolate_with(Transform3D(fixed_basis, safe_pos), 0.3)
	
	erase_query.from = held.global_position; erase_query.to = held.global_position + erase_vector
	var erase_hit := space.intersect_ray(erase_query)
	if erase_hit and erase_hit.collider.has_method(&"interact_erase"):
		erase_hit.collider.interact_erase(erase_hit.position as Vector3, not was_erasing, false); was_erasing = true; last_collider = erase_hit.collider
	elif was_erasing:
		if is_instance_valid(last_collider): last_collider.interact_erase(Vector3.ZERO, false, true)
		was_erasing = false; last_collider = null
