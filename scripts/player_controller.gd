class_name PlayerController
extends CharacterBody3D

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var camera_controller_anchor: Marker3D = $RotationAnchor/CameraControllerAnchor
@onready var rotation_anchor: Node3D = $RotationAnchor
@export var animation_player: AnimationPlayer

@export_group("Camera")
@export var mouse_sensitivity : float = 0.003
@export var min_pitch : float = -89.0 # Limite olhar para baixo
@export var max_pitch : float = 89.0 # Limite olhar para cima

@export_group("Input Actions")
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"
@export var input_sprint : String = "sprint"
@export var input_crouch : String = "crouch"
@export var input_freefly : String = "freefly"

@export var has_gravity : bool = true
@export var can_move : bool = true
@export var can_sprint : bool = true
@export var can_crouch : bool = true
@export var can_jump : bool = true
@export var can_freefly : bool = true

@export_group("Speeds")
@export var base_speed : float = 7.0
@export var sprint_speed : float = 10.0
@export var crouch_speed : float = 4.5
@export var jump_velocity : float = 4.5
@export var freefly_speed : float = 25.0

var mouse_captured : bool = false
var mouse_input : Vector2 = Vector2.ZERO
var move_speed : float = 0.0
var freeflying : bool = false
var crouching : bool = false

func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
		
	if event is InputEventMouseMotion and mouse_captured:
		mouse_input.x += -event.relative.x * mouse_sensitivity
		mouse_input.y += -event.relative.y * mouse_sensitivity
	
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()
			
func _process(_delta: float) -> void:
	if mouse_input == Vector2.ZERO: return
	
	# 1. Rodar o RotationAnchor (Esquerda/Direita)
	rotation_anchor.rotate_y(mouse_input.x)
	
	# 2. Rodar a CameraAnchor (Cima/Baixo)
	camera_controller_anchor.rotate_x(mouse_input.y)
	camera_controller_anchor.rotation.x = clamp(camera_controller_anchor.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	
	mouse_input = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (camera_controller_anchor.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	var is_crouching_input = Input.is_action_pressed(input_crouch) and is_on_floor()
	
	if can_crouch and is_crouching_input:
		move_speed = crouch_speed
		
		# CRUCIAL: Só dá play se não estiver já a tocar!
		if animation_player and animation_player.current_animation != "crouch":
			animation_player.play("crouch")
			
	elif can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
		# (Opcional) if animation_player: animation_player.play("run")
	else:
		move_speed = base_speed

	
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (rotation_anchor.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()
	
func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false
	
func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
	
