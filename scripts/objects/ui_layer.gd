extends MeshInstance3D

signal unfocused

@export var viewport: SubViewport
@export var screen_width: float = 2.86
@export var screen_height: float = 1.64

var is_mouse_down: bool = false
var last_pos_2d: Vector2 = Vector2.ZERO

func _ready() -> void:
	unfocused.connect(on_unfocused)

func interact_ui(hit_position_global: Vector3, is_just_pressed: bool, is_released: bool) -> void:
	var local = to_local(hit_position_global)
	last_pos_2d = Vector2(
		((local.x / screen_width) + 0.5) * viewport.size.x,
		(0.5 - (local.y / screen_height)) * viewport.size.y)
	
	send_motion(last_pos_2d)
	if is_just_pressed and not is_mouse_down:
		is_mouse_down = true
		send_click(last_pos_2d, true)
	elif is_released and is_mouse_down:
		is_mouse_down = false
		send_click(last_pos_2d, false)

func on_unfocused() -> void:
	if not viewport: return
	send_motion(Vector2(-1000, -1000))
	if is_mouse_down:
		is_mouse_down = false
		send_click(last_pos_2d, false)

func send_motion(pos: Vector2) -> void:
	var event = InputEventMouseMotion.new()
	event.position = pos
	event.global_position = pos
	viewport.push_input(event)

func send_click(pos: Vector2, pressed: bool) -> void:
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = pos
	event.pressed = pressed
	viewport.push_input(event)
