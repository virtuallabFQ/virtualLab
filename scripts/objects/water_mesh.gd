extends MeshInstance3D

@export_group("Liquid Simulation")
@export_range (0.0, 1.0, 0.001) var liquid_mobility: float = 0.1 

@export var springConstant = 200
@export var reaction = 4
@export var dampening = 3

@onready var pos1 : Vector3 = global_transform.origin
@onready var pos2 : Vector3 = pos1
@onready var pos3 : Vector3 = pos2

var vel : float = 0.0
var accell : Vector2
var coeff : Vector2
var coeff_old : Vector2
var coeff_old_old : Vector2

var active_material: ShaderMaterial

func _ready() -> void:
	if mesh and mesh.surface_get_material(0):
		active_material = mesh.surface_get_material(0) as ShaderMaterial
	elif material_override:
		active_material = material_override as ShaderMaterial
	
	if active_material:
		active_material = active_material.duplicate()
		if material_override: 
			material_override = active_material
		else: 
			set_surface_override_material(0, active_material)

func _physics_process(delta: float) -> void:
	if not active_material: return
	
	var accell_3d: Vector3 = (pos3 - 2 * pos2 + pos1) * 3600.0
	pos1 = pos2
	pos2 = pos3
	
	pos3 = global_transform.origin + rotation 
	
	accell = Vector2(accell_3d.x + accell_3d.y, accell_3d.z + accell_3d.y)
	coeff_old_old = coeff_old
	coeff_old = coeff
	coeff = (-springConstant * coeff_old - reaction * accell) / 3600.0 + 2 * coeff_old - coeff_old_old - delta * dampening * (coeff_old - coeff_old_old)
	
	active_material.set_shader_parameter("coeff", coeff * liquid_mobility)
	
	if (pos1.distance_to(pos3) < 0.01):
		vel = clampf(vel - delta * 1.0, 0.0, 1.0)
	else:
		vel = 1.0
		
	active_material.set_shader_parameter("vel", vel)
