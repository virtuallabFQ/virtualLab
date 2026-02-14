extends StaticBody3D

@onready var viewport = $SubViewport

var screen_width = 2.86
var screen_height = 1.64
var is_mouse_down = false

func interact_ui(hit_position_global: Vector3, is_just_pressed: bool, is_released: bool):
	var local_hit = to_local(hit_position_global)
	var mapped_x = ((local_hit.x / screen_width) + 0.5) * viewport.size.x
	var mapped_y = (0.5 - (local_hit.y / screen_height)) * viewport.size.y
	var pos_2d = Vector2(mapped_x, mapped_y)
	
	var event_motion = InputEventMouseMotion.new()
	event_motion.position = pos_2d
	event_motion.global_position = pos_2d
	viewport.push_input(event_motion)
	
	if is_just_pressed and not is_mouse_down:
		is_mouse_down = true
		send_mouse_click(pos_2d, true)
	elif is_released and is_mouse_down:
		is_mouse_down = false
		send_mouse_click(pos_2d, false)

func clear_hover():
	var event_motion = InputEventMouseMotion.new()
	event_motion.position = Vector2(-1000, -1000) 
	event_motion.global_position = Vector2(-1000, -1000)
	viewport.push_input(event_motion)

func send_mouse_click(pos: Vector2, pressed: bool):
	var event_click = InputEventMouseButton.new()
	event_click.button_index = MOUSE_BUTTON_LEFT
	event_click.position = pos
	event_click.pressed = pressed
	viewport.push_input(event_click)
