class_name DoorComponent extends Node

enum DoorType {sliding, rotating}
enum DoorStatus {open, closed}

@export var door_type : DoorType
@export var door_size : Vector3
@export var movement_direction : Vector3
@export var rotation : Vector3 = Vector3(0,1,0)
@export var rotation_amount : float = 90.0
@export var close_automatically : bool = false
@export var close_time : float = 2.0
@export var speed : float = 0.5
@export var transition : Tween.TransitionType
@export var easing : Tween.EaseType

var parent
var orig_pos : Vector3
var orig_rot : Vector3
var door_status : DoorStatus = DoorStatus.closed

func _ready() -> void:
	parent = get_parent()
	orig_pos = parent.position
	orig_rot = parent.rotation
	parent.ready.connect(connect_parent)

func connect_parent() -> void:
	parent.connect("interacted", Callable(self, "check_door"))

func open_door() -> void:
	door_status = DoorStatus.open
	var tween = get_tree().create_tween()
	match door_type:
		DoorType.sliding:
			tween.tween_property(parent, "position", orig_pos + (movement_direction * door_size), speed).set_trans(transition).set_ease(easing)
	match door_type:
		DoorType.rotating:
			tween.tween_property(parent, "rotation", orig_rot + (rotation * deg_to_rad(rotation_amount)), speed).set_trans(transition).set_ease(easing)
	
	if close_automatically:
		tween.tween_interval(close_time)
		tween.tween_callback(close_door)

func close_door() -> void:
	door_status = DoorStatus.closed
	var tween = get_tree().create_tween()
	match door_type:
		DoorType.sliding:
			tween.tween_property(parent, "position", orig_pos, speed).set_trans(transition).set_ease(easing)
	match door_type:
		DoorType.rotating:
			tween.tween_property(parent, "rotation", orig_rot, speed).set_trans(transition).set_ease(easing)
			
func check_door() -> void:
	match door_status:
		DoorStatus.closed:
			open_door()
		DoorStatus.open:
			close_door()
