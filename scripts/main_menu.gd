extends Control

@export var menu : Control
@export var options : Control
@export var animation_player : AnimationPlayer

enum state { menu, options}
var ui_state = state.menu

func _input(event):
	if event.is_action_pressed("ui_cancel") and not animation_player.is_playing():
		match ui_state:
			state.options:
				ui_state = state.menu
				hide_and_show("options", "menu")

func hide_and_show(first: String, second: String):
	animation_player.play("hide_" + first)
	await animation_player.animation_finished
	animation_player.play("show_" + second)

func _on_button_1_pressed() -> void:
	ui_state = state.menu
	if animation_player.is_playing():
		return
	animation_player.play("hide_menu")
	await animation_player.animation_finished
	Global.game_controller.change_gui_scene("res://scenes/levels/lab.tscn")

func _on_button_2_pressed() -> void:
	ui_state = state.options
	hide_and_show("menu", "options")

func _on_button_3_pressed() -> void:
	get_tree().quit()
