extends Control

signal back_to_main_menu

@export var buttons : Control
@export var graphics_menu : Control
@export var audio_menu : Control
@export var camera_menu : Control
@export var animation_player : AnimationPlayer

enum substate {options, camera, graphics, audio}
var ui_state = substate.options

@onready var menu_map = {
	substate.options: {"node": buttons, "anim": "options"},
	substate.camera: {"node": camera_menu, "anim": "camera"},
	substate.graphics: {"node": graphics_menu, "anim": "graphics"},
	substate.audio: {"node": audio_menu, "anim": "audio"}
}

func _ready() -> void:
	for state_key in menu_map:
		var menu_node = menu_map[state_key]["node"]
		if menu_node: menu_node.visible = (state_key == substate.options)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		on_exit_submenu()

func on_exit_submenu() -> bool:
	if animation_player.is_playing(): return true
	if ui_state == substate.options:
		back_to_main_menu.emit()
		return false
	change_sub_menu(substate.options)
	return true

func change_sub_menu(new_state: substate) -> void:
	if animation_player.is_playing() or ui_state == new_state: return
	var old_anim = menu_map[ui_state]["anim"]
	var new_anim = menu_map[new_state]["anim"]
	ui_state = new_state
	animation_player.play("hide_" + old_anim)
	await animation_player.animation_finished
	
	for state_key in menu_map:
		if menu_map[state_key]["node"]:
			menu_map[state_key]["node"].visible = (state_key == new_state)
	animation_player.play("show_" + new_anim)

func on_camera_controls_button_pressed() -> void:
	change_sub_menu(substate.camera)

func on_graphic_button_pressed() -> void:
	change_sub_menu(substate.graphics)

func on_audio_button_pressed() -> void:
	change_sub_menu(substate.audio)
