class_name LidComponent extends Node
 
signal lid_opened
signal lid_closed
 
@export var lid_node: RigidBody3D
@export var target_body: Node3D
@export var pick_up_component: PickUpComponent
@export var container_pick_up: PickUpComponent
@export var is_closed: bool = true
 
var relative_transform: Transform3D
var _scene_root: Node
 
func _ready():
	if pick_up_component:
		pick_up_component.toggled.connect(_on_pickup_toggled)
	if container_pick_up:
		container_pick_up.toggled.connect(_on_container_pickup_toggled)
 
	if lid_node and target_body:
		if target_body is CollisionObject3D:
			lid_node.add_collision_exception_with(target_body)
		if is_closed:
			_lock_lid()
 
	await get_tree().physics_frame
 
	if lid_node and target_body:
		relative_transform = target_body.global_transform.affine_inverse() * lid_node.global_transform
		_scene_root = lid_node.get_parent()
 
func interact():
	if is_closed:
		open_lid()
 
func open_lid():
	if not lid_node or not is_closed:
		return
 
	is_closed = false
	lid_node.freeze = false
	lid_node.sleeping = false
 
	lid_opened.emit()

func _lock_lid():
	lid_node.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	lid_node.freeze = true
	lid_node.linear_velocity = Vector3.ZERO
	lid_node.angular_velocity = Vector3.ZERO
 
func _physics_process(_delta: float) -> void:
	if is_closed and lid_node and target_body:
		lid_node.global_transform = target_body.global_transform * relative_transform
 
func _on_container_pickup_toggled(is_held: bool):
	if not lid_node or not target_body or not is_closed:
		return
 
	var player := Global.player
 
	if is_held:
		lid_node.reparent(target_body)
		lid_node.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		lid_node.freeze = true
		
		if player:
			player.add_collision_exception_with(lid_node)
	else:
		if player:
			player.remove_collision_exception_with(lid_node)
		if _scene_root and is_instance_valid(_scene_root):
			lid_node.reparent(_scene_root)
		relative_transform = target_body.global_transform.affine_inverse() * lid_node.global_transform
		_lock_lid()
 
func _on_pickup_toggled(is_held: bool):
	if is_held:
		is_closed = false
		lid_opened.emit()
	else:
		if lid_node and not is_closed:
			lid_node.freeze = false
