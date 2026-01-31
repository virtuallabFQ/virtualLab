class_name IdleState extends MovementState

@export var speed : float = 5.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25

func enter() -> void:
	animation.pause()

func update(delta):
	player.update_gravity(delta)
	player.update_input(speed,acceleration,deceleration)
	player.update_velocity()

	if Input.is_action_just_pressed("crouch") and player.is_on_floor():
		transition.emit("CrouchingState")

	if player.velocity.length() > 0.0 and player.is_on_floor():
		transition.emit("WalkingState")
