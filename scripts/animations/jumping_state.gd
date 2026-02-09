class_name JumpingState extends MovementState

@export var speed : float = 6.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var jump_velocity : float = 3.0
@export_range(0.5, 1.0, 0.01) var input_multiplier : float = 0.85

func enter(_previous_state = null) -> void:
	player.velocity.y += jump_velocity
	animation.play("jump_start")

func update(delta):
	player.update_gravity(delta)
	player.update_input(speed * input_multiplier, acceleration, deceleration)
	player.update_velocity()
			
	if player.is_on_floor():
		if Input.is_action_pressed("crouch"):
			transition.emit("CrouchingState")
		else:
			animation.play("jump_end")
			transition.emit("IdleState")
