class_name PlayerController extends CharacterBody3D

const TILT_MIN := -1.5708
const TILT_MAX := 1.5708

@onready var rotation_anchor: Node3D = $RotationAnchor
@onready var camera_controller_anchor: Node3D = %CameraControllerAnchor
@onready var camera: Camera3D = %Camera3D
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var crouch_cast: ShapeCast3D = %ShapeCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_group("Camera")
@export var interact_distance: float = 2.0
@export var zoom_key: Key = KEY_Z
@export var zoom_fov: float = 30.0
@export var zoom_speed: float = 12.0

@export_group("Movement Input")
@export var input_left: StringName = &"ui_left"
@export var input_right: StringName = &"ui_right"
@export var input_forward: StringName = &"ui_up"
@export var input_back: StringName = &"ui_down"
@export var input_jump: StringName = &"ui_accept"
@export var input_sprint: StringName = &"sprint"
@export var input_crouch: StringName = &"crouch"

var move_speed: float = 0.0
var move_accel: float = 0.0
var move_decel: float = 0.0
var crouching: bool = false
var toggle_crouch: bool = false
var is_seated: bool = false
var is_zooming: bool = false

var mouse_input: bool = false
var rotation_input: float = 0.0
var tilt_input: float = 0.0
var mouse_rotation: Vector3 = Vector3.ZERO

var interact_cast_result: Node3D = null
var held_object: Node3D = null

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	
func _ready() -> void:
	Global.player = self
	toggle_crouch = Global.toggle_crouch
	if camera: camera.fov = Global.player_fov
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	crouch_cast.add_exception(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input = true
		rotation_input -= event.relative.x * Global.mouse_sensitivity
		tilt_input -= event.relative.y * Global.mouse_sensitivity
		
func _process(delta: float) -> void:
	if camera:
		is_zooming = Input.is_physical_key_pressed(zoom_key) 
		
		var target_fov = zoom_fov if is_zooming else Global.player_fov
		camera.fov = lerpf(camera.fov, float(target_fov), zoom_speed * delta)
	
	if not mouse_input: return 
	
	mouse_rotation.x = clampf(mouse_rotation.x + tilt_input, TILT_MIN, TILT_MAX)
	mouse_rotation.y += rotation_input
	
	camera_controller_anchor.rotation.x = mouse_rotation.x
	rotation_anchor.rotation.y = mouse_rotation.y
	
	rotation_input = 0.0
	tilt_input = 0.0
	mouse_input = false

func perform_movement(delta: float) -> void:
	if is_seated: return
	
	velocity.y -= gravity * delta
	var input := Input.get_vector(input_left, input_right, input_forward, input_back)
	
	if input == Vector2.ZERO:
		velocity.x = move_toward(velocity.x, 0.0, move_decel)
		velocity.z = move_toward(velocity.z, 0.0, move_decel)
	else:	
		var dir := (rotation_anchor.global_basis * Vector3(input.x, 0.0, input.y)).normalized()
		velocity.x = lerp(velocity.x, dir.x * move_speed, move_accel)
		velocity.z = lerp(velocity.z, dir.z * move_speed, move_accel)
	move_and_slide()
