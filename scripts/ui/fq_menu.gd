extends Control

@onready var manager = get_parent()

@export var fq_menu: Control
@export var q10_menu: Control
@export var animation_player: AnimationPlayer

enum Substate { FQ, Q10 }
var ui_state := Substate.FQ

@onready var menus: Array[Control] = [fq_menu, q10_menu]

const HIDES: Array[StringName] = [&"hide_fq", &"hide_q10"]
const SHOWS: Array[StringName] = [&"show_fq", &"show_q10"]
const PANEL_ANIMS: Array[StringName] = [&"show_panel", &"hide_panel"] 

func _ready() -> void:
	for i in range(menus.size()):
		if menus[i]: 
			menus[i].visible = (i == ui_state)
			menus[i].modulate.a = 1.0 if (i == ui_state) else 0.0

func change_sub_menu(new_state: Substate) -> void:
	if animation_player.is_playing() or manager.animation_player.is_playing() or ui_state == new_state: return
	
	var old_state := ui_state
	ui_state = new_state
	animation_player.play(HIDES[old_state])
	manager.animation_player.play(PANEL_ANIMS[new_state])
	await animation_player.animation_finished
	
	if menus[old_state]: menus[old_state].visible = false
	if menus[new_state]: menus[new_state].visible = true
	
	animation_player.play(SHOWS[new_state])

func _on_al_chemistry_pressed() -> void:
	change_sub_menu(Substate.Q10)

func _on_back_button_pressed() -> void:
	manager.change_sub_menu(manager.Substate.SELECTOR)
