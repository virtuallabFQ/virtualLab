class_name LiquidTargetComponent extends Node

@export var required_group: StringName = &""
@export var visual_node_name: String = ""
@export var ghost_mesh: Node3D
@export var lid_component: LidComponent
@export var action_context: String = "Encher"
@export var needs_parent_frozen: bool = false
@export var lock_parent_while_filling: bool = true

var is_focused: bool = false
var is_ready: bool = false
var is_filling: bool = false
var original_context: String = ""
var inter_comp: Node
var snapped_bottle: RigidBody3D
var _parent_was_frozen: bool = false
var hijacked_events := {}

const ACTIONS = [&"jump", &"crouch", &"sprint", &"ui_accept", &"ui_up", &"ui_down", &"ui_left", &"ui_right"]

func _ready() -> void:
	if ghost_mesh:
		ghost_mesh.visible = false
	call_deferred(&"_setup_signals")

func _setup_signals() -> void:
	var p := get_parent()
	inter_comp = p.get_node_or_null(^"InteractionComponent")
	if inter_comp:
		original_context = inter_comp.get(&"context")
	
	if p.has_user_signal(&"focused"):
		p.connect(&"focused", func(): is_focused = true)
		p.connect(&"unfocused", func():
			is_focused = false
			_update_state(false)
		)
		p.connect(&"interacted", _on_interact)

func _process(_delta: float) -> void:
	var player := Global.player
	if not ghost_mesh or not player:
		return
		
	if is_filling:
		if not is_instance_valid(snapped_bottle) or player.held_object == snapped_bottle:
			if is_instance_valid(snapped_bottle):
				_set_jet(snapped_bottle, false, null)
			_hijack_inputs(false)
			if lock_parent_while_filling:
				_set_parent_locked(false)
			is_filling = false
			snapped_bottle = null
		return

	var lid_open := lid_component == null or not lid_component.is_closed
	var can_fill: bool = is_focused and player.held_object != null and player.held_object.is_in_group(required_group) and lid_open and (not needs_parent_frozen or get_parent().get(&"freeze") == true)
	_update_state(can_fill)
	
func _update_state(state: bool) -> void:
	if is_ready == state:
		return
	is_ready = state
	ghost_mesh.visible = state
	if inter_comp:
		var ctx := action_context if state else original_context
		inter_comp.set(&"context", ctx)
		if is_focused and MessageBus:
			MessageBus.interaction_focused.emit(ctx, inter_comp.get(&"new_icon"), inter_comp.get(&"override_icon"))

func _on_interact() -> void:
	var player := Global.player
	if not player or is_filling or not is_ready or not player.held_object:
		return
		
	snapped_bottle = player.held_object as RigidBody3D
	
	var all_pickups = get_tree().get_nodes_in_group("pickups")
	if all_pickups.is_empty():
		all_pickups = _find_all_pickups(get_tree().root, [])

	var found_pickup: PickUpComponent = null
	for p in all_pickups:
		if p is PickUpComponent and p.held_obj == snapped_bottle:
			found_pickup = p
			break
			
	if not found_pickup and player.held_object:
		for p in all_pickups:
			if p is PickUpComponent and p.held_obj == player.held_object:
				found_pickup = p
				break

	if found_pickup:
		found_pickup.call(&"_toggle", found_pickup.held_obj, false)
	
	player.held_object = null
		
	var visual := snapped_bottle.get_node_or_null(visual_node_name) as Node3D
	snapped_bottle.global_transform = ghost_mesh.global_transform * visual.transform.affine_inverse() if visual else ghost_mesh.global_transform
	snapped_bottle.linear_velocity = Vector3.ZERO
	snapped_bottle.angular_velocity = Vector3.ZERO
	snapped_bottle.freeze = true
	
	player.velocity = Vector3.ZERO
	_hijack_inputs(true)
	is_filling = true

	var recipient := get_parent().get_node_or_null("RecipientComponent") as RecipientComponent
	_set_jet(snapped_bottle, true, recipient)
	
	if lock_parent_while_filling:
		_set_parent_locked(true)
	_update_state(false)

func _set_jet(bottle: RigidBody3D, active: bool, recipient: RecipientComponent) -> void:
	if not is_instance_valid(bottle): return
	var jet := bottle.get_node_or_null("JetComponent") as JetComponent
	if jet:
		jet.is_active = active
		jet.target_recipient = recipient

func _set_parent_locked(locked: bool) -> void:
	var p := get_parent() as RigidBody3D
	if not p:
		return
	if locked:
		_parent_was_frozen = p.freeze
	p.freeze = true if locked else _parent_was_frozen
	for c in p.find_children("*", "CollisionShape3D"):
		c.set_deferred(&"disabled", locked)

func _hijack_inputs(hijack: bool) -> void:
	for act in ACTIONS:
		if not InputMap.has_action(act):
			continue
		if hijack and not hijacked_events.has(act):
			hijacked_events[act] = InputMap.action_get_events(act).duplicate()
			InputMap.action_erase_events(act)
		elif not hijack and hijacked_events.has(act):
			InputMap.action_erase_events(act)
			for ev in hijacked_events[act]:
				InputMap.action_add_event(act, ev)
	if not hijack:
		hijacked_events.clear()

func _find_all_pickups(node: Node, result: Array) -> Array:
	if node is PickUpComponent:
		result.append(node)
	for child in node.get_children():
		_find_all_pickups(child, result)
	return result
