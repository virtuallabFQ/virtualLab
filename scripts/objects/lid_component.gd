class_name LidComponent
extends Node

signal lid_opened
signal lid_closed

@export var lid_node: RigidBody3D
@export var target_body: Node3D 
@export var pick_up_component: PickUpComponent
@export var is_closed: bool = true

var relative_transform: Transform3D

func _ready():
	if lid_node and target_body:
		relative_transform = target_body.global_transform.affine_inverse() * lid_node.global_transform
		
		if target_body is CollisionObject3D:
			lid_node.add_collision_exception_with(target_body)
		
		if is_closed:
			_lock_lid()
	
	if pick_up_component:
		pick_up_component.toggled.connect(_on_pickup_toggled)

func interact():
	# Agora a interação SERVE APENAS PARA ABRIR a tampa com um clique (caso não a queiras pegar)
	if is_closed:
		open_lid()

func open_lid():
	if not lid_node or not is_closed:
		return
		
	is_closed = false
	lid_node.freeze = false
	lid_node.sleeping = false 
		
	lid_opened.emit()
	print("Tampa aberta!")

func _lock_lid():
	lid_node.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	lid_node.freeze = true
	lid_node.linear_velocity = Vector3.ZERO
	lid_node.angular_velocity = Vector3.ZERO

func _physics_process(_delta: float) -> void:
	if is_closed and lid_node and target_body:
		lid_node.global_transform = target_body.global_transform * relative_transform

func _on_pickup_toggled(is_held: bool):
	if is_held:
		is_closed = false
		lid_opened.emit()
		print("Tampa na mão!")
	else:
		if lid_node and not is_closed:
			lid_node.freeze = false
