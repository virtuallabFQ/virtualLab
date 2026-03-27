class_name WasterComponent extends Node

signal object_reset(body: Node3D)

@export var detector_path: NodePath
@onready var detector: Area3D = get_node(detector_path)

var initial_transforms: Dictionary = {}

func _ready() -> void:
	if detector:
		detector.body_entered.connect(_on_body_entered)
	call_deferred("_scan_initial_positions")

func _scan_initial_positions() -> void:
	_save_rigidbodies_positions(get_tree().current_scene)

func _save_rigidbodies_positions(node: Node) -> void:
	if node is RigidBody3D:
		initial_transforms[node] = node.global_transform
		
	for child in node.get_children():
		_save_rigidbodies_positions(child)

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D and initial_transforms.has(body):
		_reset_object(body)

func _reset_object(body: RigidBody3D) -> void:
	var interaction = body.get_node_or_null("InteractionComponent")
	if interaction:
		var pickup = interaction.get_node_or_null("PickUpComponent")
		if pickup and pickup.held_obj == body:
			pickup._toggle(body, false)
	
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	body.global_transform = initial_transforms[body]
	
	var recipient = body.get_node_or_null("RecipientComponent")
	if recipient:
		recipient.current_level = 0.0
		if recipient.liquid_mesh:
			recipient.liquid_mesh.visible = false
			recipient.liquid_pivot.scale.y = 0.001
	
	object_reset.emit(body)
