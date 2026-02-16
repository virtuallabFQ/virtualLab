class_name JumpingState extends MovementState

@export var speed := 5.0
@export var acceleration := 0.1
@export var deceleration := 0.25
@export var jump_velocity := 3.0
@export_range(0.5, 1.0, 0.01) var input_multiplier := 0.85

func enter(_prev: State = null) -> void:
	player.move_speed = speed
	player.move_accel = acceleration
	player.move_decel = deceleration
	player.velocity.y = jump_velocity
	animation.play(&"jump_start")

func update(delta: float) -> void:
	player.perform_movement(delta)
	if not player.is_on_floor(): return
	
	if Input.is_action_pressed(&"crouch"):
		transition.emit(&"CrouchingState")
	else:
		animation.play(&"jump_end")
		transition.emit(&"IdleState")
