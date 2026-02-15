class_name PickUpComponent extends Node

@export var pickup_distance: Vector3 = Vector3(0, 0, -1.0)
@export var pickup_rotation: Vector3 = Vector3.ZERO
@export var collision_margin: float = 0.2 
@export var hide_nodes: Array[Node] = []

var _obj: Node3D = null
var _rids: Array[RID] = []
var _basis: Basis

func _ready() -> void:
	_basis = Basis.from_euler(pickup_rotation * (PI / 180.0))
	var p: Node = get_parent()
	if p.has_signal(&"player_interacted"): p.connect(&"player_interacted", _pickup)

func _pickup(target: Node3D) -> void:
	if not is_instance_valid(_obj) and is_instance_valid(Global.player): _toggle(target, true)

func _input(e: InputEvent) -> void:
	if is_instance_valid(_obj) and e is InputEventMouseButton and e.button_index == 2 and e.pressed: 
		_toggle(_obj, false)

func _toggle(target: Node3D, state: bool) -> void:
	_obj = target if state else null
	var p: CharacterBody3D = Global.player
	p.held_object = _obj
	if state: p.add_collision_exception_with(target)
	else: p.remove_collision_exception_with(target)
	
	var rb: RigidBody3D = target as RigidBody3D
	if is_instance_valid(rb): rb.freeze = state
	_rids.clear()
	if state and target is CollisionObject3D:
		_rids.append(p.get_rid())
		_rids.append(target.get_rid())
	
	for n in hide_nodes:
		if is_instance_valid(n):
			n.set(&"visible", not state)
			if n.get(&"disabled") != null: n.set_deferred(&"disabled", state)

func _physics_process(_d: float) -> void:
	if not is_instance_valid(_obj) or not is_instance_valid(Global.player): return
	var cam: Camera3D = Global.player.camera
	var orig: Vector3 = cam.global_position
	var t_pos: Vector3 = cam.global_transform.translated_local(pickup_distance).origin
	var dir: Vector3 = orig.direction_to(t_pos)
	
	var q: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(orig, t_pos + (dir * collision_margin))
	q.exclude = _rids
	var res: Dictionary = _obj.get_world_3d().direct_space_state.intersect_ray(q)
	
	var safe_pos: Vector3 = orig + dir * max(orig.distance_to(res.position) - collision_margin, 0.15) if res else t_pos
	_obj.global_transform = _obj.global_transform.interpolate_with(Transform3D(cam.global_basis * _basis, safe_pos), 0.3)
