class_name SprintingState extends MovementState

@export var speed : float = 7.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var top_anim_speed : float = 1.6

func enter(_previous_state = null) -> void:
	if animation.is_playing() and animation.current_animation == "jump_end":
		await animation.animation_finished
		animation.play("sprinting",0.5,1.0)
	else:
		animation.play("sprinting",0.5,1.0)

func update(delta):
	player.update_gravity(delta)
	player.update_input(speed, acceleration, deceleration)
	player.update_velocity()
	
	set_animation_speed(player.velocity.length())
	
	if Input.is_action_just_released("sprint"):
		transition.emit(&"WalkingState")
		
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition.emit(&"JumpingState")
		
	if player.velocity.y > -3.0 and !player.is_on_floor():
		transition.emit(&"FallingState")

func set_animation_speed(spd) -> void:
	var alpha = remap(spd, 0.0, speed, 0.0, 1.0)
	animation.speed_scale = lerp(0.0, top_anim_speed, alpha)
