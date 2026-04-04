class_name PickUpComponent extends Node
 
signal toggled(is_held: bool)
 
@export var distance := Vector3(0.2, -0.3, -0.75)
@export var rotation := Vector3.ZERO
@export var margin := 0.2
@export var hide_nodes: Array[Node] = []
 
@export_group("Scroll Settings")
@export var allow_scroll := true
@export var scroll_step := 0.2
@export var min_scroll_z := -0.75
@export var max_scroll_z := -2.0
 
@export_group("Rotation Settings")
@export var rotate_key: Key = KEY_V
@export var rotate_speed := 3.0
@export var spin_axis := Vector3.UP
@export var keep_upright := true
 
@export_group("Inspect Settings")
@export var inspect_position := Vector3(0.0, -0.065, -1.0)
 
@export_group("Depth Indicator")
@export var show_depth_ray: bool = true
@export var depth_ray_color: Color = Color(1.0, 1.0, 1.0, 0.157)
@export var depth_ray_thickness: float = 0.004
@export var depth_ray_max: float = 20.0
 
var _held_scale: Vector3
var held_obj: Node3D
var base_rot: Basis
var current_local_rot: Basis
var ray_query := PhysicsRayQueryParameters3D.new()
var cached_cam: Camera3D
 
var _depth_mesh: MeshInstance3D
var _depth_cyl: CylinderMesh
var _depth_ray_query := PhysicsRayQueryParameters3D.new()
var _depth_current_length: float = 0.0
 
@onready var current_scroll_z := distance.z 
@onready var base_offset := Vector2(distance.x, distance.y)
@onready var base_z := distance.z
 
func _ready() -> void:
	set_physics_process(false); set_process_input(false)
	base_rot = Basis.from_euler(rotation * 0.01745329)
	var p := get_parent()
	if p.has_signal(&"player_interacted"): p.connect(&"player_interacted", _on_interact)
 
func _on_interact(target: Node3D) -> void:
	var player := Global.player
	if player and not player.held_object: _toggle(target, true)
 
func _input(event: InputEvent) -> void: 
	var mb := event as InputEventMouseButton 
	if not mb or not mb.pressed: return
	
	if mb.button_index == MOUSE_BUTTON_RIGHT: _toggle(held_obj, false)
	elif allow_scroll and held_obj:
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP: 
			current_scroll_z = clampf(current_scroll_z - scroll_step, max_scroll_z, min_scroll_z)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN: 
			current_scroll_z = clampf(current_scroll_z + scroll_step, max_scroll_z, min_scroll_z)
 
func _toggle(target: Node3D, state: bool) -> void:
	var player := Global.player
	held_obj = target if state else null; player.held_object = held_obj
	set_physics_process(state); set_process_input(state)
	
	if target is RigidBody3D: target.freeze = state
	
	var all_bodies := target.find_children("*", "CollisionObject3D", true, false)
	if target is CollisionObject3D: 
		all_bodies.append(target)
	
	var exclude_rids = [player.get_rid()]
	
	if state:
		current_local_rot = base_rot
		current_scroll_z = base_z
		cached_cam = player.camera as Camera3D
		
		for body in all_bodies:
			player.add_collision_exception_with(body)
			exclude_rids.append(body.get_rid())
			
		ray_query.exclude = exclude_rids
		_depth_ray_query.exclude = exclude_rids
		
		if show_depth_ray:
			_create_depth_mesh()
	else:
		for body in all_bodies:
			player.remove_collision_exception_with(body)
		cached_cam = null
		_destroy_depth_mesh()
		
	for n in hide_nodes:
		if is_instance_valid(n):
			n.set(&"visible", not state)
			if &"disabled" in n: n.set_deferred(&"disabled", state)
	toggled.emit(state)
 
func _physics_process(delta: float) -> void:
	var player = Global.player
	var speed = 12.0
	var is_inspecting = false
	
	if player and "is_zooming" in player:
		speed = player.zoom_speed 
		is_inspecting = player.is_zooming
	
	if Input.is_physical_key_pressed(rotate_key):
		is_inspecting = true
		current_local_rot = current_local_rot.rotated((current_local_rot * spin_axis).normalized(), rotate_speed * delta)
		
	if is_inspecting:
		distance.x = lerpf(distance.x, inspect_position.x, speed * delta)
		distance.y = lerpf(distance.y, inspect_position.y, speed * delta)
		distance.z = lerpf(distance.z, inspect_position.z, speed * delta)
	else:
		distance.x = lerpf(distance.x, base_offset.x, speed * delta)
		distance.y = lerpf(distance.y, base_offset.y, speed * delta)
		distance.z = lerpf(distance.z, current_scroll_z, speed * delta)
 
	var cam_basis := cached_cam.global_basis
	var orig := cached_cam.global_position
	var offset := cam_basis * distance
	var dir := offset.normalized()
	
	ray_query.from = orig; ray_query.to = orig + offset + (dir * margin)
	var hit := held_obj.get_world_3d().direct_space_state.intersect_ray(ray_query)
	var safe_pos := orig + dir * maxf((hit.position as Vector3 - orig).dot(dir) - margin, 0.15) if hit else orig + offset
	
	var ref_basis := cam_basis
	if keep_upright:
		var fwd := -cam_basis.z; fwd.y = 0.0
		ref_basis = Basis.looking_at(fwd.normalized() if fwd.length_squared() > 0.001 else -cam_basis.y, Vector3.UP)
	
	held_obj.global_transform = held_obj.global_transform.interpolate_with(Transform3D(ref_basis * current_local_rot, safe_pos), 0.3)
	
	if show_depth_ray and is_instance_valid(_depth_mesh):
		_update_depth_ray(held_obj.global_position)
 
func _create_depth_mesh() -> void:
	_depth_mesh = MeshInstance3D.new()
	_depth_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := StandardMaterial3D.new()
	mat.albedo_color = depth_ray_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_depth_mesh.material_override = mat
	_depth_cyl = CylinderMesh.new()
	_depth_cyl.top_radius = depth_ray_thickness
	_depth_cyl.bottom_radius = depth_ray_thickness
	_depth_cyl.height = 0.01
	_depth_cyl.radial_segments = 6
	_depth_cyl.rings = 1
	_depth_mesh.mesh = _depth_cyl
	_depth_current_length = 0.0
	get_tree().current_scene.add_child(_depth_mesh)
 
func _destroy_depth_mesh() -> void:
	if is_instance_valid(_depth_mesh):
		_depth_mesh.queue_free()
	_depth_mesh = null
	_depth_cyl = null
	_depth_current_length = 0.0
 
func _update_depth_ray(from: Vector3) -> void:
	var ray_start: Vector3 = from + Vector3.UP * 0.05
	_depth_ray_query.from = ray_start
	_depth_ray_query.to = ray_start + Vector3.DOWN * depth_ray_max
	var hit := held_obj.get_world_3d().direct_space_state.intersect_ray(_depth_ray_query)
	
	var target_end: Vector3 = hit.position if hit else ray_start + Vector3.DOWN * depth_ray_max
	var target_length: float = from.distance_to(target_end)
	if target_length < 0.01:
		_depth_mesh.visible = false
		return
	
	_depth_current_length = lerpf(_depth_current_length, target_length, 0.2)
	_depth_mesh.visible = true
	_depth_cyl.height = _depth_current_length
	
	var to: Vector3 = from + Vector3.DOWN * _depth_current_length
	var mid: Vector3 = (from + to) * 0.5
	_depth_mesh.global_position = mid
	_depth_mesh.global_basis = Basis(Vector3.RIGHT, (to - from).normalized(), Vector3.FORWARD)
