class_name InteractionComponent extends Node

signal player_interacted(object: Node)

@export var mesh: MeshInstance3D = null
@export var context: String = ""
@export var override_icon: bool = false
@export var new_icon: Texture2D = null

var _parent: Node = null
const highlight_material: BaseMaterial3D = preload("res://assets/materials/interactable_highlight.tres")

func _ready() -> void:
	_parent = get_parent() as Node
	_connect_parent()
	_set_default_mesh()

func in_range() -> void:
	if is_instance_valid(mesh): 
		mesh.material_overlay = highlight_material
	MessageBus.interaction_focused.emit(context, new_icon, override_icon)

func not_in_range() -> void:
	if is_instance_valid(mesh): 
		mesh.material_overlay = null
	MessageBus.interaction_unfocused.emit()

func on_interact() -> void:
	player_interacted.emit(_parent)

func _connect_parent() -> void:
	if not is_instance_valid(_parent): return
	_parent.add_user_signal(&"focused")
	_parent.add_user_signal(&"unfocused")
	_parent.add_user_signal(&"interacted")
	
	_parent.connect(&"focused", in_range)
	_parent.connect(&"unfocused", not_in_range)
	_parent.connect(&"interacted", on_interact)

func _set_default_mesh() -> void:
	if not is_instance_valid(mesh) and is_instance_valid(_parent):
		var children: Array[Node] = _parent.get_children()
		for child in children:
			var m: MeshInstance3D = child as MeshInstance3D
			if is_instance_valid(m):
				mesh = m
				break
