class_name SittingComponent extends Node

@export var sit_marker: Marker3D
@export var interaction_component: InteractionComponent

var is_occupied: bool = false
var current_player: PlayerController = null

func _ready() -> void:
	set_process_unhandled_key_input(false)
	if interaction_component:
		interaction_component.player_interacted.connect(_on_interacted)

func _on_interacted(_object: Node) -> void:
	if is_occupied or not sit_marker: return
	var player = Global.player
	if not player or player.is_seated: return
	
	is_occupied = true
	current_player = player
	
	player.is_seated = true
	player.velocity = Vector3.ZERO
	player.set_process_unhandled_input(false) 
	player.collider.set_deferred("disabled", true)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var sit_duration = 1.0
	
	tween.tween_property(player, "global_position", sit_marker.global_position, sit_duration)
	tween.tween_property(player, "mouse_rotation:y", sit_marker.global_rotation.y, sit_duration)
	tween.tween_property(player, "mouse_rotation:x", 0.0, sit_duration)
	
	tween.chain().tween_callback(func():
		player.set_process_unhandled_input(true)
		set_process_unhandled_key_input(true)
	)

func _unhandled_key_input(event: InputEvent) -> void:
	if not is_occupied or not current_player: return
	
	if event.is_action_pressed(current_player.input_jump):
		stand_up()

func stand_up() -> void:
	set_process_unhandled_key_input(false)
	is_occupied = false
	
	var forward_dir = -current_player.rotation_anchor.global_basis.z
	current_player.global_position += (Vector3.UP * 0.5) + (forward_dir * 0.5)
	current_player.is_seated = false
	current_player.collider.set_deferred("disabled", false)
	current_player = null
