class_name SnapComponent extends Node

@export var target_group: StringName = &""
@export var visual_node_name: String = ""
@export var ghost_mesh: Node3D
@export var interaction_area: Area3D 
@export var interaction_comp: InteractionComponent
@export var lock_parent_on_snap: bool = false
@export var needs_parent_frozen: bool = false

@export_group("Lid Settings")
@export var requires_open_lid: bool = false
@export var lid_component: LidComponent

var is_snapped: bool = false
var snapped_obj: RigidBody3D

func _ready() -> void:
	if ghost_mesh: ghost_mesh.visible = false
	_set_area_enabled(false)
	if interaction_comp: interaction_comp.player_interacted.connect(_on_snap)

func _process(_delta: float) -> void:
	var player := Global.player
	if not player: return
	
	if is_snapped:
		if is_instance_valid(snapped_obj) and player.held_object == snapped_obj:
			var parent_body := snapped_obj.get_parent() as CollisionObject3D
			
			# --- CORREÇÃO DE COLISÃO AQUI ---
			var lid = snapped_obj.get_node_or_null("LidComponent")
			if lid:
				lid.is_closed = false # Avisa que a tampa saiu para o funil poder entrar
			elif parent_body: 
				# Só tira a exceção de colisão se NÃO FOR uma tampa (ex: um funil)
				snapped_obj.remove_collision_exception_with(parent_body)
			# --------------------------------
			
			if lock_parent_on_snap: _set_parent_pickup_locked(false)
			is_snapped = false
			snapped_obj.reparent(get_tree().current_scene) 
			snapped_obj = null
		return
		
	var parent := get_parent() as RigidBody3D
	var block_snap: bool = false
	
	if needs_parent_frozen and parent and not parent.freeze:
		block_snap = true
		
	if requires_open_lid and lid_component and lid_component.is_closed:
		block_snap = true

	if block_snap:
		if ghost_mesh: ghost_mesh.visible = false
		_set_area_enabled(false)
		return

	var held := player.held_object as RigidBody3D
	var can_snap := held and held.is_in_group(target_group)
	
	if ghost_mesh: ghost_mesh.visible = can_snap
	_set_area_enabled(can_snap)

func _on_snap(_node: Node) -> void:
	if requires_open_lid and lid_component and lid_component.is_closed:
		return
		
	var held := Global.player.held_object as RigidBody3D
	if not held or not ghost_mesh or not held.is_in_group(target_group): return
	
	var pickups := held.find_children("*", "PickUpComponent")
	if not pickups.is_empty(): 
		var pickup_node: Node = pickups[0]
		pickup_node.call(&"_toggle", held, false)
	
	var parent_body := ghost_mesh.get_parent() as CollisionObject3D
	held.reparent(parent_body)
	if parent_body: held.add_collision_exception_with(parent_body)
	
	var visual_node := held.get_node_or_null(visual_node_name) as Node3D
	held.global_transform = ghost_mesh.global_transform * visual_node.transform.affine_inverse() if visual_node else ghost_mesh.global_transform
	
	held.linear_velocity = Vector3.ZERO
	held.angular_velocity = Vector3.ZERO
	held.freeze = true
	is_snapped = true
	snapped_obj = held
	
	# --- AVISA QUE A TAMPA FECHOU ---
	var lid = held.get_node_or_null("LidComponent")
	if lid:
		lid.is_closed = true
	# --------------------------------
	
	if lock_parent_on_snap: _set_parent_pickup_locked(true)
	if ghost_mesh: ghost_mesh.visible = false
	_set_area_enabled(false)

func _set_area_enabled(state: bool) -> void:
	if not interaction_area: return
	for i in interaction_area.get_children():
		if i is CollisionShape3D:
			i.set_deferred(&"disabled", not state)

func _set_parent_pickup_locked(state: bool) -> void:
	var parent := get_parent() as RigidBody3D
	if not parent: return
	var pickups := parent.find_children("*", "PickUpComponent")
	if not pickups.is_empty():
		var p = pickups[0]
		if "disabled" in p: p.set("disabled", state)
