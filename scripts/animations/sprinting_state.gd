class_name SprintingState extends MovementState

@export var speed := 6.5
@export var acceleration := 0.1
@export var deceleration := 0.25
@export var top_anim_speed := 1.6
var is_active := false

func enter(_prev: State = null) -> void:
	is_active = true
	player.move_speed = speed
	player.move_accel = acceleration
	player.move_decel = deceleration
	
	if animation.current_animation == &"jump_end" and animation.is_playing():
		await animation.animation_finished
	if is_active: animation.play(&"sprinting", 0.5, 1.0)

func exit() -> void:
	is_active = false
	animation.speed_scale = 1.0

func update(delta: float) -> void:
	player.perform_movement(delta)
	
	var current_speed := player.velocity.length()
	if is_active: animation.speed_scale = (current_speed / speed) * top_anim_speed
	
	if not player.is_on_floor():
		if player.velocity.y > -3.0:
			transition.emit(&"FallingState")
		return
		
	if Input.is_action_just_released(&"sprint"):
		transition.emit(&"WalkingState")
	elif Input.is_action_just_pressed(&"jump"):
		transition.emit(&"JumpingState")
	elif current_speed < 0.01:
		transition.emit(&"IdleState")
