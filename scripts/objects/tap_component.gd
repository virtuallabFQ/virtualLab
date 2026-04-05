class_name TapComponent extends Node
 
@export var source_recipient: RecipientComponent
@export var interaction: InteractionComponent
@export var drop_particles: GPUParticles3D
@export var tap_exit: Node3D
@export var flow_speed: float = 0.05
@export var max_receive_distance: float = 0.2
@export var context_open: String = "Abrir torneira"
@export var context_close: String = "Fechar torneira"
 
var is_open: bool = false
 
func _ready() -> void:
	if interaction:
		interaction.player_interacted.connect(_on_tap_interacted)
		interaction.set(&"context", context_open)
	if drop_particles:
		drop_particles.emitting = false
 
func _on_tap_interacted(_node: Node) -> void:
	is_open = not is_open
	if drop_particles:
		drop_particles.emitting = is_open
	if interaction:
		var ctx := context_close if is_open else context_open
		interaction.set(&"context", ctx)
		MessageBus.interaction_focused.emit(ctx, interaction.get(&"new_icon"), interaction.get(&"override_icon"))
 
func _get_target_recipient() -> RecipientComponent:
	if not tap_exit:
		return null
 
	var exit_pos: Vector3 = tap_exit.global_position
	var best: Node = null
	var best_dist: float = INF
 
	for node in get_tree().get_nodes_in_group("tap_receiver"):
		if not node is Node3D: continue
		var dist: float = exit_pos.distance_to((node as Node3D).global_position)
		if dist < best_dist and dist < max_receive_distance:
			best_dist = dist
			best = node
 
	if not best:
		return null
 
	var r := best.get_node_or_null("RecipientComponent") as RecipientComponent
	if r: return r
	for child in best.get_children():
		r = child.get_node_or_null("RecipientComponent") as RecipientComponent
		if r: return r
	return null
 
func _process(delta: float) -> void:
	if not is_open:
		return
	if not is_instance_valid(source_recipient):
		return
	if source_recipient.test_fill_volume <= 0.0:
		is_open = false
		if drop_particles:
			drop_particles.emitting = false
		if interaction:
			var ctx := context_open
			interaction.set(&"context", ctx)
			MessageBus.interaction_focused.emit(ctx, interaction.get(&"new_icon"), interaction.get(&"override_icon"))
		return
 
	var target := _get_target_recipient()
	var amount := flow_speed * delta
	# converte % do source em ml e depois em % do target
	var ml := amount * source_recipient.capacity_ml
	source_recipient.add_liquid(-amount)
	if target:
		target.add_liquid(ml / target.capacity_ml)
