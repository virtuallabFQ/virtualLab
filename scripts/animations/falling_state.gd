class_name FallingState extends MovementState

@export var speed := 5.0
@export var acceleration := 0.1
@export var deceleration := 0.25

func enter(_prev: State = null) -> void:
	player.move_speed = speed
	player.move_accel = acceleration
	player.move_decel = deceleration
	animation.pause()

func update(delta: float) -> void:
	player.perform_movement(delta)
	if player.is_on_floor():
		animation.play(&"jump_end")
		transition.emit(&"IdleState")
