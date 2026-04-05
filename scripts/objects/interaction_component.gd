class_name InteractionComponent extends Node

signal player_interacted(object: Node)

@export var body: Node3D
@export var context: String = ""
@export var override_icon: bool = false
@export var new_icon: Texture2D

var is_interacted: bool = false
var _target_meshes: Array[MeshInstance3D] = []

const highlight := preload("res://assets/materials/interactable_highlight.tres")

func _ready() -> void:
	var parent_node := get_parent()
	if not parent_node: return
	
	if body:
		if body is MeshInstance3D:
			_target_meshes.append(body)
		else:
			var found_meshes = body.find_children("*", "MeshInstance3D", true, false)
			for m in found_meshes:
				_target_meshes.append(m as MeshInstance3D)
	else:
		for child_node in parent_node.get_children():
			if child_node is MeshInstance3D:
				_target_meshes.append(child_node)
	
	for signal_name in [&"focused", &"unfocused", &"interacted"]: 
		if not parent_node.has_user_signal(signal_name):
			parent_node.add_user_signal(signal_name)

	parent_node.connect(&"focused", func():
		for mesh in _target_meshes:
			mesh.material_overlay = highlight
		MessageBus.interaction_focused.emit(context, new_icon, override_icon)
	)
	
	parent_node.connect(&"unfocused", func():
		for mesh in _target_meshes:
			mesh.material_overlay = null
		MessageBus.interaction_unfocused.emit()
	)
	
	parent_node.connect(&"interacted", func():
		is_interacted = true 
		player_interacted.emit(parent_node)
	)
