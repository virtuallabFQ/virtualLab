class_name PauseMenu extends Control

@export var pause_menu : Control
@export var options_menu : Control
@export var animation_player : AnimationPlayer
@onready var options_anim_player = $OptionsMenu/AnimationPlayer 

var is_closing = false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	if options_menu.has_signal("exit_options_menu"):
		options_menu.exit_options_menu.connect(close_options)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			handle_esc_input()
		elif not get_tree().paused:
			pause_game()
		get_viewport().set_input_as_handled()

func pause_game():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	visible = true
	pause_menu.visible = true
	options_menu.visible = false
	is_closing = false
	
	if animation_player.has_animation("show_pause"):
		animation_player.play("show_pause")

func handle_esc_input():
	if is_closing: return
	
	if options_menu.visible:
		close_options()
	else:
		resume_game()

func on_resume_pressed():
	resume_game()

func resume_game():
	is_closing = true
	
	if animation_player.has_animation("hide_pause"):
		animation_player.play("hide_pause")
		await animation_player.animation_finished

	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_options_pressed():
	pause_menu.visible = false
	options_menu.visible = true
	if options_anim_player and options_anim_player.has_animation("show_options"):
		options_anim_player.play("show_options")

func close_options():
	options_menu.visible = false
	pause_menu.visible = true
	if options_anim_player and options_anim_player.has_animation("hide_options"):
		options_anim_player.play("hide_options")

func on_quit_pressed():
	get_tree().paused = false
	Global.game_controller.change_3d_scene("res://virtualLab/scenes/levels/lobby.tscn")
