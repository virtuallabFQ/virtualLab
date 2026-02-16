class_name IdleState extends MovementState

@export var speed := 5.0
@export var acceleration := 0.1
@export var deceleration := 0.25

var is_active := false

func enter(_prev: State = null) -> void:
	is_active = true
	player.move_speed = speed
	player.move_accel = acceleration
	player.move_decel = deceleration
	
	if animation.current_animation == &"jump_end" and animation.is_playing(): 
		await animation.animation_finished
	if is_active: animation.pause()

func exit() -> void:
	is_active = false

func update(delta: float) -> void:
	player.perform_movement(delta)
	
	if not player.is_on_floor():
		if player.velocity.y > -3.0: transition.emit(&"FallingState")
		return
		
	if Input.is_action_just_pressed(&"jump"):
		transition.emit(&"JumpingState")
	elif Input.is_action_just_pressed(&"crouch"):
		transition.emit(&"CrouchingState")
	elif player.velocity.length_squared() > 0.001:
		transition.emit(&"WalkingState")
