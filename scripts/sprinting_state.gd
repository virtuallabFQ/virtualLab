class_name SprintingState extends MovementState

@export var speed : float = 7.0
@export var acceleration : float = 0.1
@export var deceleration : float = 0.25
@export var top_anim_speed : float = 1.6

func enter() -> void:
	animation.play("sprinting", 0.5, 1.0)

func update(delta):
	player.update_gravity(delta)
	player.update_input(speed, acceleration, deceleration)
	player.update_velocity()
	
	set_animation_speed(player.velocity.length())
	
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingState")

func set_animation_speed(spd) -> void:
	var alpha = remap(spd, 0.0, speed, 0.0, 1.0)
	animation.speed_scale = lerp(0.0, top_anim_speed, alpha)
