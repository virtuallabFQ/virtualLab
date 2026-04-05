class_name SpatulaComponent extends Node

@export var powder_mesh: MeshInstance3D

var is_full: bool = false

func _ready() -> void:
	if powder_mesh:
		powder_mesh.visible = false

func fill() -> void:
	is_full = true
	powder_mesh.visible = true

func empty() -> void:
	is_full = false
	powder_mesh.visible = false
