class_name SplashScreenManager extends Control

@export var load_scene : PackedScene
@export var in_time : float = 0.5
@export var fade_in_time : float = 1.5
@export var pause_time : float = 1.5
@export var fade_out_time : float = 1.5
@export var out_time : float = 0.5
@export var splash_screen_container : Node

var splash_screens : Array[CanvasItem] = []
var skipped : bool = false
var current_tween: Tween = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_screens()
	fade()

func get_screens() -> void:
	if not splash_screen_container: return
	var children: Array[Node] = splash_screen_container.get_children()
	for child in children:
		var screen: CanvasItem = child as CanvasItem
		if screen:
			screen.modulate.a = 0.0
			splash_screens.append(screen)

func fade() -> void:
	for screen in splash_screens:
		if skipped: break
		current_tween = create_tween()
		current_tween.tween_interval(in_time)
		current_tween.tween_property(screen, ^"modulate:a", 1.0, fade_in_time)
		current_tween.tween_interval(pause_time)
		current_tween.tween_property(screen, ^"modulate:a", 0.0, fade_out_time)
		current_tween.tween_interval(out_time)
		await current_tween.finished	
	if not skipped:
		skipped = true
		Global.game_controller.change_gui_scene("res://scenes/levels/lobby.tscn")
	
func _input(event: InputEvent) -> void:
	if skipped: return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseButton and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed(&"ui_skip") or (event is InputEventMouseButton and event.pressed):
		skipped = true
		if is_instance_valid(current_tween):
			current_tween.kill() 
		Global.game_controller.change_gui_scene("res://scenes/levels/lobby.tscn")
