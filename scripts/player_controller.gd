class_name PlayerController
extends CharacterBody3D

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var camera_controller_anchor: Marker3D = $RotationAnchor/CameraControllerAnchor
@onready var rotation_anchor: Node3D = $RotationAnchor
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var crouch_shapecast: ShapeCast3D = %ShapeCast3D

@export var mouse_sensitivity : float = 0.003
@export var tilt_lower_limit := deg_to_rad(-90.0)
@export var tilt_upper_limit := deg_to_rad(90.0)

@export_group("Input Actions")
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"
@export var input_sprint : String = "sprint"
@export var input_crouch : String = "crouch"
@export var input_freefly : String = "freefly"

@export var speed_default : float = 7.0
@export var speed_sprint : float = 10.0
@export var speed_crouch : float = 4.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var jump_velocity : float = 4.0
@export var freefly_speed : float = 25.0
@export var toggle_crouch : bool = true

var speed : float
var crouching : bool = false
var mouse_input : bool = false
var rotation_input : float
var tilt_input : float
var mouse_rotation : Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
	mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if mouse_input:
		rotation_input = -event.relative.x * mouse_sensitivity
		tilt_input = -event.relative.y * mouse_sensitivity
		
func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
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
	
func _ready():

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	speed = speed_default ##

	# add crouch check shapecast collision exception for CharacterBody3D node
	crouch_shapecast.add_exception($".")

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
