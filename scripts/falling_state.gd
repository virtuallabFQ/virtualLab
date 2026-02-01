class_name FallingState extends MovementState

@export var speed : float = 5.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25

func enter(_previous_state = null) -> void:
	animation.pause()

func update(delta: float) -> void:
	player.update_gravity(delta)
	player.update_input(speed, acceleration, deceleration)
	player.update_velocity()
		
	if player.is_on_floor():
		animation.play("jump_end")
		transition.emit("IdleState")
