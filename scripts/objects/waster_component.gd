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
		var scene_root: Node = body
		var path = body.get(&"scene_file_path")
		
		if path == null or (typeof(path) == TYPE_STRING and path.is_empty()):
			var current = body.get_parent()
			while current and current != get_tree().current_scene:
				var p = current.get(&"scene_file_path")
				if p != null and typeof(p) == TYPE_STRING and not p.is_empty():
					scene_root = current
					break
				current = current.get_parent()
				
		if not initials.has(scene_root):
			var root_path = scene_root.get(&"scene_file_path")
			if root_path != null and typeof(root_path) == TYPE_STRING and not root_path.is_empty():
				
				var mass_dict := {}
				if scene_root is RigidBody3D:
					mass_dict[str(scene_root.get_path_to(scene_root))] = scene_root.mass
				for child in scene_root.find_children(&"*", &"RigidBody3D", true, false):
					mass_dict[str(scene_root.get_path_to(child))] = child.mass
				
				initials[scene_root] = [scene_root.global_transform, load(root_path), scene_root.get_parent(), mass_dict]

func _on_body(body: Node3D) -> void:
	if body is RigidBody3D:
		body.sleeping = false
		
	if not body is RigidBody3D:
		return
	
	var target: Node = body
	if not initials.has(target):
		var current = body.get_parent()
		while current and current != get_tree().current_scene:
			if initials.has(current):
				target = current
				break
			current = current.get_parent()
	
	if target.has_meta(&"wasting"): return
	target.set_meta(&"wasting", true)
	
	call_deferred(&"_replace_object", target)

func _replace_object(body: Node3D) -> void:
	if not is_instance_valid(body):
		return
	
	var to_reset := [body]
	for child in body.find_children(&"*", &"RigidBody3D", true, false):
		to_reset.append(child)
			
	for obj in to_reset:
		if not is_instance_valid(obj):
			continue
		
		for pickup in obj.find_children(&"*", &"PickUpComponent", true, false):
			if pickup.get(&"held_obj") == obj:
				pickup.call(&"_toggle", obj, false)
				break
	
	var original_transform: Transform3D = body.global_transform
	var packed_scene: PackedScene = null
	var original_parent: Node = get_tree().current_scene
	var mass_dict := {}
	
	if initials.has(body):
		var data = initials[body]
		original_transform = data[0]
		packed_scene = data[1]
		original_parent = data[2] if is_instance_valid(data[2]) else original_parent
		mass_dict = data[3]
	else:
		var path = body.get(&"scene_file_path")
		if path != null and typeof(path) == TYPE_STRING and not path.is_empty():
			packed_scene = load(path)
			original_parent = body.get_parent()
			
	if packed_scene:
		var clone := packed_scene.instantiate() as Node3D
		original_parent.add_child(clone)
		clone.global_transform = original_transform
		
		for path_str in mass_dict:
			var rb = clone.get_node_or_null(path_str)
			if rb is RigidBody3D:
				rb.mass = mass_dict[path_str]
		
		if initials.has(body):
			initials.erase(body)
			initials[clone] = [original_transform, packed_scene, original_parent, mass_dict]
			
		object_reset.emit(clone)
		
	body.queue_free()
