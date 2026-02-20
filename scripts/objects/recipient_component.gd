class_name RecipientComponent extends Node

@export var liquid_mesh: MeshInstance3D
@onready var liquid_pivot: Node3D = liquid_mesh.get_parent() 

@export var fill_speed := 0.2
@export var max_height := 1.0

var current_level := 0.0

func _ready() -> void:
	if liquid_mesh:
		liquid_mesh.visible = false
		liquid_pivot.scale.y = 0.001 

func receive_liquid(delta: float, material: Material) -> void:
	if not liquid_mesh or current_level >= 1.0: return
	
	if not liquid_mesh.visible:
		liquid_mesh.visible = true
		if material: liquid_mesh.material_override = material
	
	current_level = clampf(current_level + (delta * fill_speed), 0.0, 1.0)
	
	var target_scale = max(0.001, current_level * max_height)
	
	liquid_pivot.scale.y = target_scale
