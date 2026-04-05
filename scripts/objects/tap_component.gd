class_name TapComponent extends Node
 
@export var source_recipient: RecipientComponent
@export var interaction: InteractionComponent
@export var drop_particles: GPUParticles3D
@export var tap_exit: Node3D
@export var receive_area: Area3D
@export_range(0.0, 10.0, 0.0001, "or_greater") var drop_interval: float = 1.0
@export_range(0.0, 1.0, 0.0001, "or_greater") var ml_per_drop: float = 0.05
@export var max_receive_distance: float = 10.0
@export var context_open: String = "Abrir torneira"
@export var context_close: String = "Fechar torneira"
@export_range(0.0, 5.0, 0.0001, "or_greater") var source_visual_scale: float = 1.0
@export_range(0.0, 5.0, 0.0001, "or_greater") var target_visual_scale: float = 1.0
 
var is_open: bool = false
var drop_count: int = 0
var _time_since_last_drop: float = 0.0
 
func _ready() -> void:
	if interaction:
		interaction.player_interacted.connect(_on_tap_interacted)
		interaction.set(&"context", context_open)
	if drop_particles:
		drop_particles.emitting = false
 
func _on_tap_interacted(_node: Node) -> void:
	is_open = not is_open
	if not is_open:
		drop_count = 0
		_time_since_last_drop = 0.0
	if drop_particles:
		drop_particles.emitting = is_open
	if interaction:
		var ctx := context_close if is_open else context_open
		interaction.set(&"context", ctx)
		if MessageBus:
			MessageBus.interaction_focused.emit(ctx, interaction.get(&"new_icon"), interaction.get(&"override_icon"))
 
func _get_target_recipient() -> RecipientComponent:
	if not tap_exit:
		return null
 
	var space_state := tap_exit.get_world_3d().direct_space_state
	var start_pos := tap_exit.global_position
	var end_pos := start_pos + (Vector3.DOWN * max_receive_distance)
	
	var query := PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	query.collide_with_areas = true 
	query.collide_with_bodies = true
	query.collision_mask = 0xFFFFFFFF
	
	var parent_body := _get_parent_body(self)
	if parent_body:
		query.exclude = [parent_body.get_rid()]
	
	var result := space_state.intersect_ray(query)
	
	if not result or not result.collider:
		return null
	
	var hit_node: Node = result.collider
	
	if hit_node.name == "room" or hit_node.name == "Lab":
		return null
	
	var current_search = hit_node
	for i in range(3):
		if not current_search: break
		
		var recipients := current_search.find_children("*", "RecipientComponent", true, false)
		for r in recipients:
			if r is RecipientComponent and r != source_recipient:
				return r
		
		if current_search.has_node("RecipientComponent"):
			var r := current_search.get_node("RecipientComponent")
			if r is RecipientComponent and r != source_recipient:
				return r
				
		current_search = current_search.get_parent()
		
	return null
 
func _get_parent_body(node: Node) -> CollisionObject3D:
	var current := node.get_parent()
	while current:
		if current is CollisionObject3D:
			return current as CollisionObject3D
		current = current.get_parent()
	return null
 
func _process(delta: float) -> void:
	if not is_open or not is_instance_valid(source_recipient): 
		return
		
	if source_recipient.test_fill_volume <= 0.0:
		is_open = false
		if drop_particles: 
			drop_particles.emitting = false
		if interaction:
			interaction.set(&"context", context_open)
			if MessageBus:
				MessageBus.interaction_focused.emit(context_open, interaction.get(&"new_icon"), interaction.get(&"override_icon"))
		return
	
	_time_since_last_drop += delta
	if _time_since_last_drop >= drop_interval:
		_time_since_last_drop -= drop_interval
		drop_count += 1
		print("Gotas: ", drop_count)
 
	var target := _get_target_recipient()
	var flow_speed := (ml_per_drop / drop_interval) / source_recipient.capacity_ml
	var amount := flow_speed * delta
	var ml := amount * source_recipient.capacity_ml
 
	source_recipient.add_liquid(-amount * source_visual_scale)
	
	if target:
		target.add_liquid((ml / target.capacity_ml) * target_visual_scale)
