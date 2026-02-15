class_name TransitionController extends Control

@export var background: ColorRect
@export var animation_player: AnimationPlayer

func transition(anim: StringName, sec: float) -> void:
	mouse_filter = MOUSE_FILTER_STOP
	if background: background.mouse_filter = MOUSE_FILTER_STOP
	
	if animation_player: 
		animation_player.play(anim, -1.0, 1.0 / max(sec, 0.001))
		await animation_player.animation_finished
	if anim == &"fade_in": 
		mouse_filter = MOUSE_FILTER_IGNORE
		if background: background.mouse_filter = MOUSE_FILTER_IGNORE
