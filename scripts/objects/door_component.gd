class_name DoorComponent extends Node

enum DoorType {SLIDING, ROTATING}

@export var door_type: DoorType
@export var door_size: Vector3
@export var movement_direction: Vector3
@export var rotation := Vector3(0, 1, 0)
@export var rotation_amount := 90.0
@export var close_automatically := false
@export var close_time := 2.0
@export var speed := 0.5
@export var transition: Tween.TransitionType
@export var easing: Tween.EaseType

var parent_node: Node3D 
var is_open := false 
var property: StringName
var closed_value: Vector3 
var open_value: Vector3
var current_tween: Tween

func _ready() -> void:
	parent_node = get_parent() as Node3D; if not parent_node: return
	property = &"position" if door_type == DoorType.SLIDING else &"rotation"
	closed_value = parent_node.get(property)
	open_value = closed_value + (movement_direction * door_size if door_type == DoorType.SLIDING else rotation * deg_to_rad(rotation_amount))
	await parent_node.ready; parent_node.connect(&"interacted", _toggle)

func _toggle() -> void:
	is_open = not is_open
	if current_tween: current_tween.kill()
	current_tween = create_tween().set_trans(transition).set_ease(easing)
	current_tween.tween_property(parent_node, NodePath(property), open_value if is_open else closed_value, speed)
	if is_open and close_automatically: current_tween.tween_interval(close_time); current_tween.tween_callback(_toggle)
