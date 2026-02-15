class_name PlayerController extends CharacterBody3D

@onready var rotation_anchor: Node3D = $RotationAnchor
@onready var camera_controller_anchor: Node3D = %CameraControllerAnchor
@onready var camera: Camera3D = %Camera3D
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var crouch_shapecast: ShapeCast3D = %ShapeCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_group("Camera")
@export var tilt_lower_limit := deg_to_rad(-90.0)
@export var tilt_upper_limit := deg_to_rad(90.0)
@export var interact_distance : float = 2

@export_group("Movement Settings")
@export var speed_default : float = 7.0
@export var speed_sprint : float = 10.0
@export var speed_crouch : float = 4.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var jump_velocity : float = 4.0
@export var freefly_speed : float = 25.0
@export var toggle_crouch : bool = true

@export_group("Movement Input")
@export var input_left: StringName = &"ui_left"
@export var input_right: StringName = &"ui_right"
@export var input_forward: StringName = &"ui_up"
@export var input_back: StringName = &"ui_down"
@export var input_jump: StringName = &"ui_accept"
@export var input_sprint: StringName = &"sprint"
@export var input_crouch: StringName = &"crouch"
@export var input_freefly: StringName = &"freefly"

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") as float

var speed : float
var crouching : bool = false
var mouse_input : bool = false
var rotation_input: float = 0.0
var tilt_input: float = 0.0
var mouse_rotation: Vector3 = Vector3.ZERO
var interact_cast_result: Node3D = null
var held_object : Node3D = null

func _ready():
	Global.player = self
	if camera: camera.fov = Global.player_fov
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	speed = speed_default ##
	crouch_shapecast.add_exception(self)

func _unhandled_input(event: InputEvent) -> void:
	mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if mouse_input:
		rotation_input = -event.relative.x * Global.mouse_sensitivity
		tilt_input = -event.relative.y * Global.mouse_sensitivity
		
func _process(delta):
	_update_camera(delta)

func _update_camera(_delta):
	mouse_rotation.x += tilt_input
	mouse_rotation.x = clamp(mouse_rotation.x, tilt_lower_limit, tilt_upper_limit)
	mouse_rotation.y += rotation_input

	camera_controller_anchor.rotation.x = mouse_rotation.x
	rotation_anchor.rotation.y = mouse_rotation.y

	rotation_input = 0.0
	tilt_input = 0.0

func update_camera_settings():
	if camera:
		camera.fov = Global.player_fov

func update_gravity(delta) -> void:
	velocity.y -= gravity * delta

func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (rotation_anchor.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x,direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z,direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)

func update_velocity() -> void:
	move_and_slide()
