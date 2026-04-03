class_name WasterComponent extends Node

signal object_reset(body: Node3D)

@export var detector: Area3D

var initials := {}

func _ready() -> void:
	if detector:
		detector.body_entered.connect(_on_body)
	await get_tree().process_frame
	_scan()

func _scan() -> void:
	for body in get_tree().current_scene.find_children(&"*", &"RigidBody3D", true, false):
		if not body.scene_file_path.is_empty():
			initials[body] = [body.global_transform, load(body.scene_file_path), body.get_parent()]

func _on_body(body: Node3D) -> void:
	if body is RigidBody3D:
		body.sleeping = false
		
	if not body is RigidBody3D or not initials.has(body):
		return
	
	call_deferred(&"_replace_object", body)

func _replace_object(body: Node3D) -> void:
	if not is_instance_valid(body) or not initials.has(body):
		return
	
	var to_reset := [body]
	for child in body.find_children(&"*", &"RigidBody3D", true, false):
		if initials.has(child):
			to_reset.append(child)
			
	for obj in to_reset:
		if not is_instance_valid(obj) or not initials.has(obj):
			continue
			
		for collision in obj.find_children(&"*", &"", true, false):
			if &"held_obj" in collision and collision.get(&"held_obj") == obj:
				collision.call(&"_toggle", obj, false)
				break 
		
		var data = initials[obj]
		var clone := (data[1] as PackedScene).instantiate() as Node3D
		
		var original_parent := data[2] as Node if is_instance_valid(data[2]) else get_tree().current_scene
		original_parent.add_child(clone)
		
		var original_transform: Transform3D = data[0]
		clone.global_transform = original_transform
		
		initials.erase(obj)
		initials[clone] = data
		object_reset.emit(clone)
		
	body.queue_free()
