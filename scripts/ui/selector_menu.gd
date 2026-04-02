extends Control

@export var selector_menu: Control
@export var fq_menu: Control
@export var animation_player: AnimationPlayer

enum Substate { SELECTOR, FQ }
var ui_state := Substate.SELECTOR

@onready var menus: Array[Control] = [selector_menu, fq_menu]

const HIDES: Array[StringName] = [&"hide_selector", &"hide_fq"]
const SHOWS: Array[StringName] = [&"show_selector", &"show_fq"]

func _ready() -> void:
	for i in range(menus.size()):
		if menus[i]: 
			menus[i].visible = (i == Substate.SELECTOR)

func change_sub_menu(new_state: Substate) -> void:
	if animation_player.is_playing() or ui_state == new_state: return
	
	var old_state := ui_state
	ui_state = new_state
	animation_player.play(HIDES[old_state])
	await animation_player.animation_finished
	
	if menus[old_state]: menus[old_state].visible = false
	if menus[new_state]: menus[new_state].visible = true
	
	animation_player.play(SHOWS[new_state])

func _on_year_10_button_pressed() -> void:
	change_sub_menu(Substate.FQ)
