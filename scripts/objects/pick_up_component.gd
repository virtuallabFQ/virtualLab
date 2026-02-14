@tool
class_name PickUpComponent extends Node

@export var pickup_distance : Vector3 = Vector3(0,0,-1)
@export var pickup_rotation_degrees : Vector3 = Vector3(0, 0, 0)
@export var collision_margin : float = 0.2 
@export var nodes_to_hide_when_picked : Array[Node] = []

var parent: Node
var object : Node3D
var picked_up : bool = false
const pickup_lerp : float = 0.3

var exclude_rids : Array[RID] = []
var target_basis : Basis

func update_state(interactable: Node3D) -> void:
	if picked_up or not Global.player: return
	object = interactable
	Global.player.add_collision_exception_with(object)
	Global.player.held_object = object 
	
	if object is RigidBody3D:
		object.freeze = true
	picked_up = true
	exclude_rids.clear()
	if Global.player is CollisionObject3D: exclude_rids.append(Global.player.get_rid())
	if object is CollisionObject3D: exclude_rids.append(object.get_rid())
	
	var rot_rad = Vector3(deg_to_rad(pickup_rotation_degrees.x), deg_to_rad(pickup_rotation_degrees.y), deg_to_rad(pickup_rotation_degrees.z))
	target_basis = Basis.from_euler(rot_rad)
	toggle_nodes(false)

func drop_object() -> void:
	if not picked_up: return
	if Global.player and object:
		Global.player.remove_collision_exception_with(object)
		Global.player.held_object = null 
	toggle_nodes(true)
	
	if object is RigidBody3D:
		object.freeze = false
	picked_up = false
	object = null
	exclude_rids.clear()

func toggle_nodes(is_visible: bool) -> void:
	for node in nodes_to_hide_when_picked:
		if not node: continue
		if node is Node3D: node.visible = is_visible
		if "disabled" in node: node.set_deferred("disabled", not is_visible)

func _input(event: InputEvent) -> void:
	if picked_up and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		drop_object()

func _physics_process(_delta: float) -> void:
	if not picked_up or not is_instance_valid(object) or not Global.player: return
	var camera = Global.player.camera
	var camera_transform = camera.global_transform
	var origin = camera.global_position
	
	var target_pos = camera_transform.translated_local(pickup_distance).origin
	var dir_to_target = origin.direction_to(target_pos) 
	var check_pos = target_pos + (dir_to_target * collision_margin)
	
	var query = PhysicsRayQueryParameters3D.create(origin, check_pos)
	query.exclude = exclude_rids
	
	var result = object.get_world_3d().direct_space_state.intersect_ray(query)
	var final_transform = camera_transform
	
	if result:
		var safe_distance = max(origin.distance_to(result.position) - collision_margin, 0.15)
		final_transform.origin = origin + (dir_to_target * safe_distance)
	else:
		final_transform.origin = target_pos
	final_transform.basis *= target_basis
	object.global_transform = object.global_transform.interpolate_with(final_transform, pickup_lerp)

func _ready() -> void:
	parent = get_parent()
	if parent is InteractionComponent:
		parent.player_interacted.connect(update_state)

func _get_configuration_warnings() -> PackedStringArray:
	if parent is not InteractionComponent:
		return ["This node must have a InteractionComponent parent."]
	return []

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		parent = get_parent()
		update_configuration_warnings()
