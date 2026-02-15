class_name InteractionComponent extends Node

signal player_interacted(object)

@export var mesh : MeshInstance3D
@export var context : String
@export var override_icon : bool
@export var new_icon : Texture2D

var parent: Node
var highlight_material = preload("res://assets/materials/interactable_highlight.tres")

func _ready() -> void:
	parent = get_parent()
	connect_parent()
	set_default_mesh()

func in_range() -> void:
	if mesh: mesh.material_overlay = highlight_material
	MessageBus.interaction_focused.emit(context, new_icon, override_icon)

func not_in_range() -> void:
	if mesh: mesh.material_overlay = null
	MessageBus.interaction_unfocused.emit()

func on_interact() -> void:
	player_interacted.emit(parent)

func connect_parent() -> void:
	parent.add_user_signal("focused")
	parent.add_user_signal("unfocused")
	parent.add_user_signal("interacted")
	
	parent.connect("focused", in_range)
	parent.connect("unfocused", not_in_range)
	parent.connect("interacted", on_interact)

func set_default_mesh() -> void:
	if not mesh:
		for child in parent.get_children():
			if child is MeshInstance3D:
				mesh = child
				break
