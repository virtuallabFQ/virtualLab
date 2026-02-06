extends Control

@export var main_menu: Control
@export var options_menu: Control
@export var start_button: Control
@export var options_button: Button 

func _ready():
	main_menu.visible = true
	options_menu.visible = false
	main_menu.modulate.a = 1.0
	options_menu.modulate.a = 1.0

	start_button.pressed.connect(start_button_pressed)
	options_button.pressed.connect(options_button_pressed)

func start_button_pressed():
	Global.game_controller.change_gui_scene("res://scenes/levels/lab.tscn")

func options_button_pressed():
	menu_transition(main_menu, options_menu)

func menu_transition(hide_menu: Control, show_menu: Control):
	var tween = create_tween()
	tween.set_parallel(false)
	tween.set_trans(Tween.TRANS_SINE)

	tween.tween_property(hide_menu, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): hide_menu.visible = false)

	tween.tween_callback(func(): 
		show_menu.visible = true
		show_menu.modulate.a = 0.0
	)
	tween.tween_property(show_menu, "modulate:a", 1.0, 0.3)
