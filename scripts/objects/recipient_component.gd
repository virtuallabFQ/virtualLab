@tool
extends Node
class_name RecipientComponent

@export var liquid_mesh: MeshInstance3D
@export var fill_curve: Curve
@export var height_min: float = 0
@export var height_max: float = 15.0

@export_range(0.0, 1.0) var test_fill_volume: float = 0.0:
	set(value):
		test_fill_volume = value
		_update_visuals()

func _update_visuals() -> void:
	if not liquid_mesh: return
	
	var visual_percent = fill_curve.sample(test_fill_volume) if fill_curve else test_fill_volume
	var final_pos = lerp(height_min, height_max, visual_percent)
	liquid_mesh.set_instance_shader_parameter(&"fill_level", final_pos)
	var mat = liquid_mesh.get_surface_override_material(0)
	if mat: mat.set_shader_parameter("fill_level", final_pos)

func add_liquid(amount: float) -> void:
	test_fill_volume = clamp(test_fill_volume + amount, 0.0, 1.0)
