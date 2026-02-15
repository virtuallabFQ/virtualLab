class_name EraseComponent extends Node

@export var distance: Vector3 = Vector3(0, 0, -1.0)
@export var rotation: Vector3 = Vector3.ZERO
@export var margin: float = 0.2
@export var hide_nodes: Array[Node] = []
@export var erase_range: float = 0.8 # Distância do raio de apagar

# Escolhe qual lado do objeto é a "borracha" no Inspector
@export_enum("-Z (Frente)", "Z (Trás)", "-Y (Baixo)", "Y (Cima)", "-X (Esquerda)", "X (Direita)") var eraser_facing: int = 0
@export var debug_mode: bool = true 

var held_obj: Node3D
var base_rot: Basis
var ray_query := PhysicsRayQueryParameters3D.new()
var erase_query := PhysicsRayQueryParameters3D.new()
var cached_cam: Camera3D
var fixed_z: float = 0.0
var fixed_basis: Basis

func _ready() -> void:
	set_physics_process(false) 
	set_process_input(false)
	base_rot = Basis.from_euler(rotation * (PI / 180.0))
	var parent_node := get_parent()
	if parent_node.has_signal(&"player_interacted"):
		parent_node.connect(&"player_interacted", func(target): 
			if not held_obj and Global.player: 
				_toggle(target, true)
		)

func _input(event: InputEvent) -> void: 
	if event is InputEventMouseButton and event.button_index == 2 and event.pressed: 
		_toggle(held_obj, false)

func _toggle(target: Node3D, state: bool) -> void:
	# Correção Linha 34: Lógica limpa sem cortes
	if state:
		held_obj = target
	else:
		held_obj = null
		
	Global.player.held_object = held_obj
	set_physics_process(state)
	set_process_input(state)
	
	if state:
		fixed_z = target.global_position.z
		fixed_basis = target.global_basis
		cached_cam = Global.player.camera as Camera3D
		Global.player.add_collision_exception_with(target)
		
		# Configura raio de apagar
		erase_query.exclude = [Global.player.get_rid(), target.get_rid()]
		erase_query.collide_with_areas = true
		erase_query.collide_with_bodies = true
	else:
		cached_cam = null
		Global.player.remove_collision_exception_with(target)
	
	if target is RigidBody3D: 
		target.freeze = state
		
	if state and target is CollisionObject3D:
		ray_query.exclude = [Global.player.get_rid(), target.get_rid()]
	else:
		ray_query.exclude = []
	
	for n in hide_nodes:
		if is_instance_valid(n): 
			n.set(&"visible", not state)
			if "disabled" in n: n.set_deferred(&"disabled", state)

func _physics_process(_delta: float) -> void:
	var orig: Vector3 = cached_cam.global_position
	var offset: Vector3 = cached_cam.global_basis * distance 
	var t_pos: Vector3 = orig + offset
	var dir: Vector3 = offset.normalized()
	
	ray_query.from = orig
	ray_query.to = t_pos + (dir * margin)
	
	var hit: Dictionary = held_obj.get_world_3d().direct_space_state.intersect_ray(ray_query)
	
	# Correção Linha 56: Cálculo de safe_pos simplificado
	var safe_pos: Vector3
	if hit:
		safe_pos = orig + dir * max(orig.distance_to(hit.position) - margin, 0.15)
	else:
		safe_pos = t_pos
		
	safe_pos.z = fixed_z
	held_obj.global_transform = held_obj.global_transform.interpolate_with(Transform3D(fixed_basis, safe_pos), 0.3)
	
	_handle_erasing()

func _handle_erasing() -> void:
	if not held_obj: return

	erase_query.from = held_obj.global_position
	
	# Calcula a direção baseada na escolha do Inspector
	var direction_vec = Vector3.FORWARD
	match eraser_facing:
		0: direction_vec = -held_obj.global_basis.z # -Z (Padrão)
		1: direction_vec = held_obj.global_basis.z  # Z
		2: direction_vec = -held_obj.global_basis.y # -Y (Baixo)
		3: direction_vec = held_obj.global_basis.y  # Y
		4: direction_vec = -held_obj.global_basis.x # -X
		5: direction_vec = held_obj.global_basis.x  # X
		
	erase_query.to = held_obj.global_position + (direction_vec * erase_range)
	
	var result = held_obj.get_world_3d().direct_space_state.intersect_ray(erase_query)
	
	if result:
		var collider = result.collider
		if debug_mode: print("Apagador tocou em: ", collider.name) 
		
		if collider.has_method("erase"):
			collider.erase(result.position)
