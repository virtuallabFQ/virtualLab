@tool
extends Node
class_name RecipientComponent
 
@export var liquid_mesh: MeshInstance3D
@export var fill_curve: Curve
@export var capacity_ml: float = 100.0
 
@export_range(-1.0, 1.0, 0.0001, "or_less", "or_greater") var max_y_world: float = 0.5
 
@export_range(0.0, 1.0) var test_fill_volume: float = 0.0:
	set(value):
		test_fill_volume = value
		_update_visuals()
 
func _update_visuals() -> void:
	if not liquid_mesh: return
 
	var visual_percent = fill_curve.sample(test_fill_volume) if fill_curve else test_fill_volume
 
	var aabb := liquid_mesh.get_aabb()
	var min_y_local := minf(aabb.position.y, aabb.end.y)
 
	liquid_mesh.set_instance_shader_parameter(&"fill_percentage", visual_percent)
	liquid_mesh.set_instance_shader_parameter(&"min_y_local", min_y_local)
	liquid_mesh.set_instance_shader_parameter(&"max_y_local", max_y_world)
 
func add_liquid(amount: float) -> void:
	test_fill_volume = clamp(test_fill_volume + amount, 0.0, 1.0)
 
