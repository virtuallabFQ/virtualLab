class_name OptionsMenu extends Control

signal back_to_main_menu

@export var buttons: Control
@export var graphics_menu: Control
@export var audio_menu: Control
@export var camera_menu: Control
@export var animation_player: AnimationPlayer

enum Substate {OPTIONS, CAMERA, GRAPHICS, AUDIO}
var ui_state := Substate.OPTIONS

@onready var menu_map: Dictionary = {
	Substate.OPTIONS: {"node": buttons, "hide": &"hide_options", "show": &"show_options"},
	Substate.CAMERA: {"node": camera_menu, "hide": &"hide_camera", "show": &"show_camera"},
	Substate.GRAPHICS: {"node": graphics_menu, "hide": &"hide_graphics", "show": &"show_graphics"},
	Substate.AUDIO: {"node": audio_menu, "hide": &"hide_audio", "show": &"show_audio"}
}

func _ready() -> void:
	for state_key in menu_map:
		var menu_node: Control = menu_map[state_key]["node"]
		if menu_node: menu_node.visible = (state_key == Substate.OPTIONS)

func on_exit_submenu() -> bool:
	if animation_player.is_playing(): return true
	
	if ui_state == Substate.OPTIONS:
		back_to_main_menu.emit()
		return false
	change_sub_menu(Substate.OPTIONS)
	return true

func change_sub_menu(new_state: Substate) -> void:
	if animation_player.is_playing() or ui_state == new_state: return
	
	var old_state := ui_state
	ui_state = new_state
	animation_player.play(menu_map[old_state]["hide"])
	await animation_player.animation_finished
	
	for state_key in menu_map:
		var node: Control = menu_map[state_key]["node"]
		if node: node.visible = (state_key == new_state)
	animation_player.play(menu_map[new_state]["show"])

func on_camera_controls_button_pressed() -> void:
	change_sub_menu(Substate.CAMERA)
func on_graphic_button_pressed() -> void:
	change_sub_menu(Substate.GRAPHICS)
func on_audio_button_pressed() -> void:
	change_sub_menu(Substate.AUDIO)
