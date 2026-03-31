class_name WasterComponent extends Node

signal object_reset(body: Node3D)

@export var detector: Area3D

var initials := {}

func _ready() -> void:
	if detector: detector.body_entered.connect(_on_body)
	call_deferred("_scan")

func _scan() -> void:
	for body in get_tree().current_scene.find_children("*", "RigidBody3D", true, false):
		if not body.scene_file_path.is_empty():
			initials[body] = [body.global_transform, load(body.scene_file_path)]

func _on_body(body: Node3D) -> void:
	if not body is RigidBody3D or not initials.has(body):
		return
	
	call_deferred("_replace_object", body)

func _replace_object(body: Node3D) -> void:
	if not is_instance_valid(body) or not initials.has(body): return
	
	for collision in body.find_children("*"):
		if "held_obj" in collision and collision.get("held_obj") == body:
			collision._toggle(body, false)
			break 
	
	var data = initials[body]
	var clone = data[1].instantiate()
	body.get_parent().add_child(clone)
	clone.global_transform = data[0]
	
	initials.erase(body); body.queue_free()
	initials[clone] = data
	object_reset.emit(clone)
