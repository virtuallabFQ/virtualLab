extends Control

@onready var manager = get_parent()

@export var q10_menu: VBoxContainer
@export var al1_button: Panel
@export var al5_button: Panel
@export var animation_player: AnimationPlayer

enum Substate { AL1, AL5 }
var ui_state := Substate.AL1

@onready var menus: Array[Control] = [al1_button, al5_button]

const HIDES: Array[StringName] = [&"hide_al1", &"hide_al5"]
const SHOWS: Array[StringName] = [&"show_al1", &"show_al5"]

func _ready() -> void:
	q10_menu.visible = true
	q10_menu.modulate.a = 1.0
	
	for i in range(menus.size()):
		if menus[i]:
			menus[i].visible = (i == ui_state)
			menus[i].modulate.a = 1.0 if (i == ui_state) else 0.0

func change_sub_menu(new_state: Substate) -> void:
	if animation_player.is_playing() or ui_state == new_state: return
	
	var old_state := ui_state
	ui_state = new_state
	animation_player.play(HIDES[old_state])
	await animation_player.animation_finished
	
	if menus[old_state]: menus[old_state].visible = false
	if menus[new_state]: menus[new_state].visible = true
	
	animation_player.play(SHOWS[new_state])

func _on_al_1_pressed() -> void:
	change_sub_menu(Substate.AL1)

func _on_al_5_pressed() -> void:
	change_sub_menu(Substate.AL5)

func _on_back_button_pressed() -> void:
	manager.change_sub_menu(manager.Substate.FQ)
