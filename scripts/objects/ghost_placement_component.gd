class_name GhostPlacementComponent extends Node

@export var custom_marker: Node3D
@export var material: Material
@export var context := "Colocar"

var ghost: StaticBody3D
var parent_body: Node3D
var orig_pos: Transform3D

func _ready() -> void:
	var current_node := get_parent()
	while current_node and not current_node is Node3D: current_node = current_node.get_parent()
	parent_body = current_node as Node3D
	if not parent_body: return
	
	orig_pos = parent_body.global_transform
	var pickups := parent_body.find_children("*", "PickUpComponent")
	if pickups: pickups[0].toggled.connect(_on_pickup)

func _on_pickup(is_held: bool) -> void:
	if is_instance_valid(ghost): ghost.queue_free()
	if not is_held or not parent_body: return
	
	ghost = StaticBody3D.new()
	ghost.global_transform = custom_marker.global_transform if custom_marker else orig_pos
	if parent_body is CollisionObject3D:
		ghost.collision_layer = parent_body.collision_layer
		ghost.collision_mask = parent_body.collision_mask
	
	for child_node in parent_body.get_children():
		if child_node is Node3D:
			var clone := child_node.duplicate() as Node3D; _apply_material(clone)
			ghost.add_child(clone)
			
	var interact_comp := InteractionComponent.new()
	interact_comp.context = context
	interact_comp.player_interacted.connect(_place)
	ghost.add_child(interact_comp)
	parent_body.get_parent().add_child.call_deferred(ghost)

func _apply_material(node: Node) -> void:
	if node is MeshInstance3D and material: node.material_override = material
	for child_node in node.get_children(): _apply_material(child_node)

func _place(_node: Node) -> void:
	if Global.player.held_object != parent_body: return
	for pickup_comp in parent_body.find_children("*", "PickUpComponent"): pickup_comp._toggle(parent_body, false)
	parent_body.global_transform = ghost.global_transform
	if parent_body is RigidBody3D: parent_body.linear_velocity = Vector3.ZERO
	parent_body.angular_velocity = Vector3.ZERO
