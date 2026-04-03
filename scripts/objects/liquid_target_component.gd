class_name LiquidTargetComponent extends Node

@export var ghost_mesh: Node3D
@export var visual_node_name: String = ""
@export var action_context: String = "Encher"
@export var required_group: StringName = &"wash_bottle"
@export var needs_parent_frozen: bool = false

var is_focused: bool = false
var is_ready: bool = false
var is_filling: bool = false
var original_context: String = ""
var inter_comp: Node
var snapped_bottle: RigidBody3D

# O COFRE DO SEQUESTRO ABSOLUTO
var hijacked_events := {}
const ACTIONS = [&"jump", &"crouch", &"sprint", &"ui_accept", &"ui_up", &"ui_down", &"ui_left", &"ui_right", &"move_forward", &"move_backward", &"move_left", &"move_right"]

func _ready() -> void:
	if ghost_mesh: ghost_mesh.visible = false
	call_deferred(&"_setup_signals")

func _setup_signals() -> void:
	var parent := get_parent()
	inter_comp = parent.get_node_or_null(^"InteractionComponent")
	if inter_comp and "context" in inter_comp:
		original_context = inter_comp.get(&"context")
	if parent.has_user_signal(&"focused"):
		parent.connect(&"focused", _on_focus)
		parent.connect(&"unfocused", _on_unfocus)
		parent.connect(&"interacted", _on_interact)

func _on_focus() -> void: is_focused = true
func _on_unfocus() -> void: 
	is_focused = false
	_update_state(false)

func _process(_delta: float) -> void:
	if not ghost_mesh or is_filling: return
	var player := Global.player
	var should_be_ready := false
	
	if is_focused and player:
		var held := player.held_object as RigidBody3D
		if held and held.is_in_group(required_group):
			should_be_ready = true
			if needs_parent_frozen:
				var pb := get_parent() as RigidBody3D
				if pb and not pb.freeze: should_be_ready = false
	_update_state(should_be_ready)

func _update_state(state: bool) -> void:
	if is_ready == state: return
	is_ready = state
	ghost_mesh.visible = state
	if inter_comp:
		var ctx: String = action_context if state else original_context
		inter_comp.set(&"context", ctx)
		if is_focused: MessageBus.interaction_focused.emit(ctx, inter_comp.get(&"new_icon"), inter_comp.get(&"override_icon"))

func _on_interact() -> void:
	if is_filling or not is_ready: return
	var player := Global.player
	var held := player.held_object as RigidBody3D
	if not held or not player: return
	
	# 1. Largar o Esguicho
	for pickup in held.find_children("*", "PickUpComponent"):
		pickup.call(&"_toggle", held, false); break
	
	# 2. Posicionar
	var visual := held.get_node_or_null(visual_node_name) as Node3D
	held.global_transform = ghost_mesh.global_transform * visual.transform.affine_inverse() if visual else ghost_mesh.global_transform
	held.linear_velocity = Vector3.ZERO; held.angular_velocity = Vector3.ZERO; held.freeze = true
	
	# 3. EXECUTAR O SEQUESTRO ABSOLUTO (Direto no Motor C++)
	player.velocity = Vector3.ZERO 
	_hijack_inputs(true)
	_toggle_interaction_ray(player, false)
	MessageBus.interaction_unfocused.emit()
	
	is_filling = true
	snapped_bottle = held

func _input(event: InputEvent) -> void:
	# 4. DEVOLVER TUDO AO CLICAR DE NOVO
	if is_filling and event.is_action_pressed(&"interact"):
		var player := Global.player
		if not player: return
		
		_hijack_inputs(false)
		_toggle_interaction_ray(player, true)
		
		if is_instance_valid(snapped_bottle):
			snapped_bottle.freeze = false
			for pickup in snapped_bottle.find_children("*", "PickUpComponent"):
				pickup.call(&"_toggle", snapped_bottle, true); break
		
		is_filling = false
		snapped_bottle = null

# ==========================================
# MAGIA DE C++: APAGA AS TECLAS DA MEMÓRIA GLOBAL DO GODOT!
# ==========================================
func _hijack_inputs(hijack: bool) -> void:
	for action in ACTIONS:
		if InputMap.has_action(action):
			if hijack:
				if not hijacked_events.has(action):
					# Guarda os botões originais (ex: Espaço, Shift, W, A, S, D) e arranca-os do Godot!
					hijacked_events[action] = InputMap.action_get_events(action)
					InputMap.action_erase_events(action)
			else:
				if hijacked_events.has(action):
					# Limpa a lousa e cola os botões todos de volta!
					InputMap.action_erase_events(action)
					for ev in hijacked_events[action]:
						InputMap.action_add_event(action, ev)
	if not hijack: hijacked_events.clear()

func _toggle_interaction_ray(player: Node, active: bool) -> void:
	for ray in player.find_children("*", "RayCast3D"):
		if ray is RayCast3D: ray.enabled = active
