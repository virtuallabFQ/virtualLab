class_name GameController extends Node

@export var world_3d : Node3D
@export var world_2d : Node2D
@onready var gui: Control = $GUI
@onready var transition_controller : Control = $TransitionController

var current_3d_scene
var current_2d_scene
var current_gui_scene
var is_transitioning: bool = false

func _ready() -> void:
	Global.game_controller = self
	current_gui_scene = $GUI/SplashScreenManager
	is_transitioning = true 
	transition_controller.transition("fade_in", 0.1)
	await transition_controller.animation_player.animation_finished
	is_transitioning = false

func change_3d_scene(new_scene: String, delete:= true, keep_running:= false, transition:= true, t_in:= "fade_in", t_out:= "fade_out", secs:= 1.0) -> void:
	current_3d_scene = await perform_scene_change(world_3d, current_3d_scene, new_scene, delete, keep_running, transition, t_in, t_out, secs)

func change_2d_scene(new_scene: String, delete:= true, keep_running:= false, transition:= true, t_in:= "fade_in", t_out:= "fade_out", secs:= 1.0) -> void:
	current_2d_scene = await perform_scene_change(world_2d, current_2d_scene, new_scene, delete, keep_running, transition, t_in, t_out, secs)

func change_gui_scene(new_scene: String, delete:= true, keep_running:= false, transition:= true, t_in:= "fade_in", t_out:= "fade_out", secs:= 1.0) -> void:
	current_gui_scene = await perform_scene_change(gui, current_gui_scene, new_scene, delete, keep_running, transition, t_in, t_out, secs)

func perform_scene_change(target_node: Node, current_scene: Node, new_scene: String, delete: bool, keep_running: bool, transition: bool, t_in: String, t_out: String, secs: float) -> Node:
	is_transitioning = true
	
	if transition:
		transition_controller.transition(t_out, secs)
		await transition_controller.animation_player.animation_finished
		
	if current_scene != null:
		if delete:
			current_scene.queue_free()
		elif keep_running:
			current_scene.visible = false
		else:
			target_node.remove_child(current_scene)
			
	var new_inst = load(new_scene).instantiate()
	target_node.add_child(new_inst)
	
	if transition:
		transition_controller.transition(t_in, secs)
		await transition_controller.animation_player.animation_finished
		
	is_transitioning = false
	return new_inst
