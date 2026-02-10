extends Control

signal back_to_main_menu

@export var buttons : Control
@export var graphics_menu : Control
@export var audio_menu : Control
@export var camera_menu : Control
@export var animation_player : AnimationPlayer

enum substate {options, camera, graphics, audio}
var ui_state = substate.options

func _ready() -> void:
	if buttons: buttons.visible = true
	if camera_menu: camera_menu.visible = false
	if graphics_menu: graphics_menu.visible = false
	if audio_menu: audio_menu.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel") and not animation_player.is_playing():
		get_viewport().set_input_as_handled()
		match ui_state:
			substate.options:
				emit_signal("back_to_main_menu")
			substate.camera:
				change_sub_menu(substate.options, "camera", "options")
			substate.graphics:
				change_sub_menu(substate.options, "graphics", "options")
			substate.audio:
				change_sub_menu(substate.options, "audio", "options")

func change_sub_menu(new_state: substate, hide_name: String, show_name: String):
	ui_state = new_state
	
	animation_player.play("hide_" + hide_name)
	await animation_player.animation_finished
	animation_player.play("show_" + show_name)

func on_camera_controls_button_pressed() -> void:
	if animation_player.is_playing(): return
	change_sub_menu(substate.camera, "options", "camera")

func on_graphic_button_pressed() -> void:
	if animation_player.is_playing(): return
	change_sub_menu(substate.graphics, "options", "graphics")

func on_audio_button_pressed() -> void:
	if animation_player.is_playing(): return
	change_sub_menu(substate.audio, "options", "audio")
