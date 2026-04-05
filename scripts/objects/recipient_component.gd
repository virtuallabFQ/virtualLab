class_name RecipientComponent extends Node

@export var liquid_mesh: MeshInstance3D
@export var fill_curve: Curve
@export var capacity_ml: float = 100.0

@export_range(-1.0, 1.0, 0.0001, "or_less", "or_greater") var max_y_world: float = 0.5

@export_group("Dissolve Mechanics")
@export var powder_pivot: Node3D
@export var powder_color: Color = Color(0.1, 0.5, 0.9, 1.0)
@export_range(0.0, 100.0, 0.001, "or_greater") var dissolve_speed: float = 0.3

@export_range(0.0, 1.0) var test_fill_volume: float = 0.0:
	set(value):
		test_fill_volume = value
		_update_visuals()

var _base_mass: float = 0.0
var _current_color: Color = Color(0.780, 0.874, 1.0, 0.392)
var _target_color: Color = Color(0.780, 0.874, 1.0, 0.392)
var _base_liquid_alpha: float = 0.392
var _dissolving: bool = false
var _powder_initial_scale: Vector3 = Vector3.ONE

func _ready() -> void:
	if Engine.is_editor_hint(): return
	var rb := get_parent() as RigidBody3D
	if rb:
		_base_mass = rb.mass
	if liquid_mesh:
		liquid_mesh.set_instance_shader_parameter(&"liquid_color", _current_color)
	if powder_pivot:
		_powder_initial_scale = powder_pivot.scale

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	if powder_pivot and powder_pivot.visible and test_fill_volume > 0.0:
		_dissolving = true

	if _dissolving and powder_pivot and powder_pivot.visible:
		powder_pivot.scale -= powder_pivot.scale * dissolve_speed * delta
		_target_color = Color(powder_color.r, powder_color.g, powder_color.b, _base_liquid_alpha)
		if powder_pivot.scale.y <= 0.001:
			powder_pivot.scale = Vector3.ZERO
			powder_pivot.visible = false
			_dissolving = false

	if not _current_color.is_equal_approx(_target_color):
		_current_color = _current_color.lerp(_target_color, delta * 2.0)
		_current_color.a = _base_liquid_alpha
		if liquid_mesh:
			liquid_mesh.set_instance_shader_parameter(&"liquid_color", _current_color)

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

func reset_powder() -> void:
	if powder_pivot:
		powder_pivot.scale = _powder_initial_scale
		powder_pivot.visible = true
	_dissolving = false
