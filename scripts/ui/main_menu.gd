extends Control

@export var menu : Control
@export var options : Control
@export var animation_player : AnimationPlayer

enum state {menu, options}
var ui_state = state.menu

func _ready() -> void:
	if options.has_signal("back_to_main_menu"):
		if not options.back_to_main_menu.is_connected(on_options_back):
			options.back_to_main_menu.connect(on_options_back)

func _input(event):
	if event.is_action_pressed("ui_cancel") and not animation_player.is_playing():
		get_viewport().set_input_as_handled()
		
		match ui_state:
			state.menu:
				pass
			state.options:
				if options.has_method("on_exit_submenu"):
					options.on_exit_submenu()

func on_options_back():
	ui_state = state.menu
	hide_and_show("options", "menu")

func hide_and_show(first: String, second: String):
	animation_player.play("hide_" + first)
	await animation_player.animation_finished
	animation_player.play("show_" + second)

func on_start_button_pressed() -> void:
	ui_state = state.menu
	if animation_player.is_playing():
		return
	animation_player.play("hide_menu")
	await animation_player.animation_finished
	Global.game_controller.change_gui_scene("res://scenes/levels/lab.tscn")

func on_options_button_pressed() -> void:
	ui_state = state.options
	hide_and_show("menu", "options")

func on_exit_button_pressed() -> void:
	get_tree().quit()
