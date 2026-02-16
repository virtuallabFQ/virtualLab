class_name PauseMenu extends Control

@export var primary_menu: Control
@export var options_menu: Control
@export var animation_player: AnimationPlayer

func _ready() -> void:
	visible = false
	options_menu.visible = false
	primary_menu.visible = true
	if options_menu and options_menu.has_signal(&"back_to_main_menu"): options_menu.back_to_main_menu.connect(close_options)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"ui_cancel") or animation_player.is_playing() or (Global.game_controller and Global.game_controller.is_transitioning): return
	
	get_viewport().set_input_as_handled()
	
	if not get_tree().paused: pause()
	elif not options_menu.visible: resume()
	elif options_menu.has_method(&"on_exit_submenu"): options_menu.on_exit_submenu()
	else: close_options()

func pause() -> void:
	MessageBus.toggle_game_paused.emit(true); get_tree().paused = true; Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	primary_menu.visible = true; options_menu.visible = false; visible = true
	animation_player.play(&"show_pause")

func resume() -> void:
	MessageBus.toggle_game_paused.emit(false); animation_player.play(&"hide_pause")
	await animation_player.animation_finished
	visible = false; get_tree().paused = false; Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _switch(h: StringName, s: StringName, opt: bool) -> void:
	animation_player.play(h); await animation_player.animation_finished
	primary_menu.visible = not opt; options_menu.visible = opt
	animation_player.play(s)

func on_resume_pressed() -> void:
	if not animation_player.is_playing():
		resume()
	
func on_options_pressed() -> void:
	if not animation_player.is_playing():
		_switch(&"hide_pause", &"show_options", true)
		
func close_options() -> void:
	_switch(&"hide_options", &"show_pause", false)

func on_quit_pressed() -> void:
	get_tree().paused = false; Global.game_controller.change_gui_scene("res://scenes/levels/lobby.tscn")
