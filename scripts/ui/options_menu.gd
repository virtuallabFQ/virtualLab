class_name OptionsMenu extends Control

signal back_to_main_menu

@export var buttons: Control
@export var graphics_menu: Control
@export var audio_menu: Control
@export var camera_menu: Control
@export var animation_player: AnimationPlayer

enum Substate { OPTIONS, CAMERA, GRAPHICS, AUDIO }

var ui_state := Substate.OPTIONS

@onready var menus: Array[Control] = [buttons, camera_menu, graphics_menu, audio_menu]

const HIDES: Array[StringName] = [&"hide_options", &"hide_camera", &"hide_graphics", &"hide_audio"]
const SHOWS: Array[StringName] = [&"show_options", &"show_camera", &"show_graphics", &"show_audio"]

func _ready() -> void:
	for i in 4: if menus[i]: menus[i].visible = (i == Substate.OPTIONS)

func on_exit_submenu() -> bool:
	if animation_player.is_playing(): return true
	if ui_state == Substate.OPTIONS: back_to_main_menu.emit(); return false
	change_sub_menu(Substate.OPTIONS); return true

func change_sub_menu(new_state: Substate) -> void:
	if animation_player.is_playing() or ui_state == new_state: return
	var old_state := ui_state; ui_state = new_state
	
	animation_player.play(HIDES[old_state]); await animation_player.animation_finished
	
	if menus[old_state]: menus[old_state].visible = false
	if menus[new_state]: menus[new_state].visible = true
	
	animation_player.play(SHOWS[new_state])

func on_camera_controls_button_pressed() -> void:
	change_sub_menu(Substate.CAMERA)

func on_graphic_button_pressed() -> void:
	change_sub_menu(Substate.GRAPHICS)

func on_audio_button_pressed() -> void:
	change_sub_menu(Substate.AUDIO)
