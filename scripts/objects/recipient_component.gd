class_name RecipientComponent extends Node
 
@export var liquid_mesh: MeshInstance3D
@export var fill_curve: Curve
@export var capacity_ml: float = 100.0

@export_range(-1.0, 1.0, 0.0001, "or_less", "or_greater") var max_y_world: float = 0.5

@export_range(0.0, 1.0) var test_fill_volume: float = 0.0:
	set(value):
		test_fill_volume = value
		_update_visuals()
 
var _base_mass: float = 0.0
 
func _ready() -> void:
	if Engine.is_editor_hint(): return
	var rb := get_parent() as RigidBody3D
	if rb: 
		_base_mass = rb.mass
 
func get_liquid_ml() -> float:
	return test_fill_volume * capacity_ml 
 
func _update_visuals() -> void:
	if not liquid_mesh: return
 
	var visual_percent := fill_curve.sample(test_fill_volume) if fill_curve else test_fill_volume 
	visual_percent = clamp(visual_percent, 0.0, 1.0) 
 
	var aabb := liquid_mesh.get_aabb() 
	var min_y_local := minf(aabb.position.y, aabb.end.y) 
	
	liquid_mesh.set_instance_shader_parameter(&"fill_percentage", visual_percent) 
	liquid_mesh.set_instance_shader_parameter(&"min_y_local", min_y_local) 
	liquid_mesh.set_instance_shader_parameter(&"max_y_local", max_y_world) 
 
func add_liquid(amount: float) -> void:
	test_fill_volume = clamp(test_fill_volume + amount, 0.0, 1.0) 
	
	if Engine.is_editor_hint(): return
	
	var rb := get_parent() as RigidBody3D
	if rb:
		rb.mass = _base_mass + ((test_fill_volume * capacity_ml) / 1000.0)
