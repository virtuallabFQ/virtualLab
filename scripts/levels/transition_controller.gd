class_name TransitionController extends Control

@export var background: ColorRect
@export var animation_player: AnimationPlayer

func transition(anim: StringName, s: float) -> void:
	_filter_mode(Control.MOUSE_FILTER_STOP)
	if is_instance_valid(animation_player):
		animation_player.play(anim, -1.0, 1.0 / max(s, 0.001))
		await animation_player.animation_finished
	if anim == &"fade_in": _filter_mode(Control.MOUSE_FILTER_IGNORE)

func _filter_mode(mf: Control.MouseFilter) -> void:
	mouse_filter = mf; if is_instance_valid(background): background.mouse_filter = mf
