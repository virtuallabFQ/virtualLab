class_name GameController extends Node

@export var world_3d: Node3D
@export var world_2d: Node2D
@onready var gui := $GUI as Control
@onready var transition_controller := $TransitionController as TransitionController

var scene_3d: Node
var scene_2d: Node
var scene_gui: Node
var is_transitioning := false

func _ready() -> void:
	Global.game_controller = self; scene_gui = $GUI/SplashScreenManager
	if transition_controller: transition_controller.transition(&"fade_in", 0.1); await transition_controller.animation_player.animation_finished

func change_3d_scene(path: String, del:=true, keep:=false, do_trans:=true, anim_in:=&"fade_in", anim_out:=&"fade_out", sec:=1.0) -> void: 
	scene_3d = await _swap(world_3d, scene_3d, path, del, keep, do_trans, anim_in, anim_out, sec)

func change_2d_scene(path: String, del:=true, keep:=false, do_trans:=true, anim_in:=&"fade_in", anim_out:=&"fade_out", sec:=1.0) -> void: 
	scene_2d = await _swap(world_2d, scene_2d, path, del, keep, do_trans, anim_in, anim_out, sec)

func change_gui_scene(path: String, del:=true, keep:=false, do_trans:=true, anim_in:=&"fade_in", anim_out:=&"fade_out", sec:=1.0) -> void: 
	scene_gui = await _swap(gui, scene_gui, path, del, keep, do_trans, anim_in, anim_out, sec)

func _swap(parent: Node, current: Node, path: String, del: bool, keep: bool, do_trans: bool, anim_in: StringName, anim_out: StringName, sec: float) -> Node:
	is_transitioning = true; if do_trans and transition_controller: transition_controller.transition(anim_out, sec); await transition_controller.animation_player.animation_finished
	if current:
		if del: current.queue_free()
		elif keep: current.set(&"visible", false)
		else: parent.remove_child(current)
	var inst := (load(path) as PackedScene).instantiate(); parent.add_child(inst)
	if do_trans and transition_controller: transition_controller.transition(anim_in, sec); await transition_controller.animation_player.animation_finished
	is_transitioning = false; return inst
