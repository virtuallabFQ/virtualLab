class_name ChairComponent extends Node

@export var sit_marker: Marker3D
@export var interaction_component: InteractionComponent

var is_occupied := false

func _ready() -> void:
	if interaction_component:
		interaction_component.player_interacted.connect(_on_interacted)

func _on_interacted(_object: Node) -> void:
	if is_occupied or not sit_marker: return
	
	var sitting_state = Global.player.get_node_or_null("StateMachine/SittingState")
	
	if sitting_state and Global.player.get_node("StateMachine").current_state != sitting_state:
		is_occupied = true
		
		sitting_state.start_sitting(
			sit_marker.global_position, 
			sit_marker.global_rotation.y, 
			func(): is_occupied = false
		)
