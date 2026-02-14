extends StaticBody3D

@export var viewport : SubViewport

@export var screen_width : float = 2.86
@export var screen_height : float = 1.64

var is_mouse_down = false
var last_pos_2d = Vector2.ZERO

func _ready():
	add_user_signal("unfocused")
	connect("unfocused", on_unfocused)

func interact_ui(hit_position_global: Vector3, is_just_pressed: bool, is_released: bool):
	var local_hit = to_local(hit_position_global)
	var mapped_x = ((local_hit.x / screen_width) + 0.5) * viewport.size.x
	var mapped_y = (0.5 - (local_hit.y / screen_height)) * viewport.size.y
	last_pos_2d = Vector2(mapped_x, mapped_y)
	
	var event_motion = InputEventMouseMotion.new()
	event_motion.position = last_pos_2d
	event_motion.global_position = last_pos_2d
	viewport.push_input(event_motion)
	
	if is_just_pressed and not is_mouse_down:
		is_mouse_down = true
		send_mouse_click(last_pos_2d, true)
	elif is_released and is_mouse_down:
		is_mouse_down = false
		send_mouse_click(last_pos_2d, false)

func on_unfocused():
	var event_motion = InputEventMouseMotion.new()
	event_motion.position = Vector2(-1000, -1000) 
	event_motion.global_position = Vector2(-1000, -1000)
	viewport.push_input(event_motion)
	
	if is_mouse_down:
		is_mouse_down = false
		send_mouse_click(last_pos_2d, false)

func send_mouse_click(pos: Vector2, pressed: bool):
	var event_click = InputEventMouseButton.new()
	event_click.button_index = MOUSE_BUTTON_LEFT
	event_click.position = pos
	event_click.pressed = pressed
	viewport.push_input(event_click)
