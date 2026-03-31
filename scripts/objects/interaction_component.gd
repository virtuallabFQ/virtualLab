class_name InteractionComponent extends Node

signal player_interacted(object: Node)

@export var mesh: MeshInstance3D
@export var context: String = ""
@export var override_icon: bool = false
@export var new_icon: Texture2D

var is_interacted: bool = false

const highlight := preload("res://assets/materials/interactable_highlight.tres")

func _ready() -> void:
	var parent_node := get_parent()
	if not parent_node: return
	
	if not mesh:
		for child_node in parent_node.get_children():
			if child_node is MeshInstance3D: mesh = child_node; break
			
	for signal_name in [&"focused", &"unfocused", &"interacted"]: parent_node.add_user_signal(signal_name)

	parent_node.connect(&"focused", func():
		if mesh: mesh.material_overlay = highlight
		MessageBus.interaction_focused.emit(context, new_icon, override_icon))
	parent_node.connect(&"unfocused", func():
		if mesh: mesh.material_overlay = null
		MessageBus.interaction_unfocused.emit())
	parent_node.connect(&"interacted", func():
		is_interacted = true 
		player_interacted.emit(parent_node))
