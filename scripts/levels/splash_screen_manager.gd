class_name SplashScreenManager extends Control

@export var load_scene: PackedScene
@export var in_time := 0.5
@export var fade_in := 1.5
@export var pause := 1.5
@export var fade_out := 1.5
@export var out_time := 0.5
@export var splash_screen_container: Node

var current_tween: Tween
var skipped := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED; if not splash_screen_container: return
	for child in splash_screen_container.get_children(): if child is CanvasItem: child.modulate.a = 0.0
	_run_sequence()

func _run_sequence() -> void:
	for child in splash_screen_container.get_children():
		if skipped or not child is CanvasItem: continue
		current_tween = create_tween()
		current_tween.tween_interval(in_time); current_tween.tween_property(child, ^"modulate:a", 1.0, fade_in)
		current_tween.tween_interval(pause); current_tween.tween_property(child, ^"modulate:a", 0.0, fade_out)
		current_tween.tween_interval(out_time); await current_tween.finished
	_skip()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not skipped and (event.is_action_pressed(&"ui_skip") or (event is InputEventMouseButton and event.pressed)): _skip()

func _skip() -> void:
	if skipped: return
	skipped = true; if current_tween: current_tween.kill()
	if load_scene: Global.game_controller.change_gui_scene(load_scene.resource_path)
