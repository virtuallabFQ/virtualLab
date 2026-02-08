class_name TransitionController extends Control

@export var background : ColorRect
@export var animation_player : AnimationPlayer

func transition(animation: String, seconds: float) -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP 
	background.mouse_filter = Control.MOUSE_FILTER_STOP
  
	animation_player.play(animation, -1.0, 1 / seconds)
	await animation_player.animation_finished
	if animation == "fade_in": 
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
