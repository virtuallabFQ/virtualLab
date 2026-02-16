class_name MainMenu extends Control

enum State {MENU, OPTIONS}

@export var menu: Control
@export var options: Control
@export var animation_player: AnimationPlayer

var ui_state := State.MENU

func _ready() -> void:
	if options and options.has_signal(&"back_to_main_menu"): 
		options.back_to_main_menu.connect(on_options_back)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not animation_player.is_playing():
		get_viewport().set_input_as_handled()
		if ui_state == State.OPTIONS and options.has_method(&"on_exit_submenu"): 
			options.on_exit_submenu()

func on_options_back() -> void:
	ui_state = State.MENU
	hide_and_show(&"hide_options", &"show_menu")

func hide_and_show(first: StringName, second: StringName) -> void:
	animation_player.play(first)
	await animation_player.animation_finished; animation_player.play(second)

func on_start_button_pressed() -> void:
	if animation_player.is_playing(): return
	ui_state = State.MENU; animation_player.play(&"hide_menu")
	await animation_player.animation_finished
	Global.game_controller.change_gui_scene("res://scenes/levels/lab.tscn")

func on_options_button_pressed() -> void:
	if animation_player.is_playing(): return
	ui_state = State.OPTIONS; hide_and_show(&"hide_menu", &"show_options")

func on_exit_button_pressed() -> void:
	get_tree().quit()
