class_name CrouchingState extends MovementState

@export var speed := 3.0
@export var acceleration := 0.1
@export var deceleration := 0.25
@export_range(1, 6, 0.1) var crouch_speed := 4.0

@onready var crouch_shapecast: ShapeCast3D = %ShapeCast3D

var exiting := false
var can_exit := false

func enter(_prev: State = null) -> void:
	exiting = false
	can_exit = false
	
	player.move_speed = speed
	player.move_accel = acceleration
	player.move_decel = deceleration
	if animation.current_animation != &"crouch": 
		animation.play(&"crouch", -1.0, crouch_speed)
	await get_tree().process_frame
	
	can_exit = true

func update(delta: float) -> void:
	player.perform_movement(delta)
	if exiting or not can_exit: return
	
	if Input.is_action_just_pressed(&"crouch") if player.toggle_crouch else not Input.is_action_pressed(&"crouch"):
		uncrouch()

func uncrouch() -> void:
	if crouch_shapecast.is_colliding():
		await get_tree().physics_frame
		if not exiting: uncrouch()
		return
	
	exiting = true
	animation.play(&"crouch", -1.0, -crouch_speed * 1.5, true)
	if animation.is_playing(): 
		await animation.animation_finished
	transition.emit(&"WalkingState" if player.velocity.length_squared() > 0.01 else &"IdleState")
