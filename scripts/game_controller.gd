class_name GameController extends Node

@export var world_3d: Node3D
@export var world_2d: Node2D
@onready var gui: Control = $GUI as Control
@onready var transition_controller: TransitionController = $TransitionController as TransitionController

var current_3d_scene: Node = null
var current_2d_scene: Node = null
var current_gui_scene: Node = null
var is_transitioning: bool = false

func _ready() -> void:
	Global.game_controller = self
	current_gui_scene = $GUI/SplashScreenManager as Node
	await _play_transition(&"fade_in", 0.1)

func change_3d_scene(path: String, delete_old:=true, keep_running:=false, t:=true, i:=&"fade_in", o:=&"fade_out", s:=1.0) -> void: 
	current_3d_scene = await _swap(world_3d, current_3d_scene, path, delete_old, keep_running, t, i, o, s)

func change_2d_scene(path: String, delete_old:=true, keep_running:=false, t:=true, i:=&"fade_in", o:=&"fade_out", s:=1.0) -> void: 
	current_2d_scene = await _swap(world_2d, current_2d_scene, path, delete_old, keep_running, t, i, o, s)

func change_gui_scene(path: String, delete_old:=true, keep_running:=false, t:=true, i:=&"fade_in", o:=&"fade_out", s:=1.0) -> void: 
	current_gui_scene = await _swap(gui, current_gui_scene, path, delete_old, keep_running, t, i, o, s)

func _play_transition(anim: StringName, secs: float) -> void:
	if is_instance_valid(transition_controller):
		transition_controller.transition(anim, secs)
		await transition_controller.animation_player.animation_finished

func _swap(target_container: Node, current: Node, path: String, delete_old: bool, keep_running: bool, t: bool, t_in: StringName, t_out: StringName, s: float) -> Node:
	is_transitioning = true
	if t: await _play_transition(t_out, s)
	
	if is_instance_valid(current):
		if delete_old: current.queue_free()
		elif keep_running: current.set(&"visible", false)
		else: target_container.remove_child(current)
		
	var inst: Node = (load(path) as PackedScene).instantiate()
	target_container.add_child(inst)
	
	if t: await _play_transition(t_in, s)
	is_transitioning = false
	return inst
