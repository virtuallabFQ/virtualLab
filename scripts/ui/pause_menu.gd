class_name PauseMenu extends Control

@export var primary_menu : Control
@export var options_menu : Control
@export var animation_player : AnimationPlayer

func _ready() -> void:
	visible = false
	options_menu.visible = false
	primary_menu.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"): return
	
	if animation_player.is_playing() or Global.game_controller.is_transitioning:
		return
	get_viewport().set_input_as_handled() 
	
	if get_tree().paused:
		if options_menu.visible:
			if options_menu.has_method("on_exit_submenu") and options_menu.on_exit_submenu():
				return 
			close_options()
		else:
			resume()
	else:
		pause()

func pause() -> void:
	MessageBus.toggle_game_paused.emit(true)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	primary_menu.visible = true
	options_menu.visible = false
	visible = true
	animation_player.play("show_pause")

func resume() -> void:
	MessageBus.toggle_game_paused.emit(false)
	animation_player.play("hide_pause")
	await animation_player.animation_finished
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func open_options() -> void:
	animation_player.play("hide_pause")
	await animation_player.animation_finished
	primary_menu.visible = false
	options_menu.visible = true
	animation_player.play("show_options")

func close_options() -> void:
	animation_player.play("hide_options")
	await animation_player.animation_finished
	options_menu.visible = false
	primary_menu.visible = true
	animation_player.play("show_pause")

func on_resume_pressed() -> void:
	if !animation_player.is_playing():
		resume()

func on_options_pressed() -> void:
	if !animation_player.is_playing():
		open_options()

func on_quit_pressed() -> void:
	get_tree().paused = false
	Global.game_controller.change_gui_scene("res://scenes/levels/lobby.tscn")
