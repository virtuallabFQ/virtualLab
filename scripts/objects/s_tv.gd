extends StaticBody3D

@export var viewport: SubViewport
@export var screen_width := 2.86
@export var screen_height := 1.64

var is_mouse_down := false
var last_pos: Vector2
var viewport_size: Vector2
var event_motion := InputEventMouseMotion.new() 
var event_click := InputEventMouseButton.new()

func _ready() -> void:
	viewport_size = Vector2(viewport.size)
	event_click.button_index = MOUSE_BUTTON_LEFT
	MessageBus.interaction_unfocused.connect(func(): _send_motion(Vector2(-1000, -1000)); if is_mouse_down: _send_click(false))

func interact_ui(hit_pos: Vector3, just_pressed: bool, released: bool) -> void:
	var location := to_local(hit_pos)
	last_pos = Vector2((location.x / screen_width + 0.5) * viewport_size.x, (0.5 - location.y / screen_height) * viewport_size.y)
	_send_motion(last_pos)
	if just_pressed and not is_mouse_down: _send_click(true)
	elif released and is_mouse_down: _send_click(false)

func _send_motion(pos: Vector2) -> void: 
	event_motion.position = pos; event_motion.global_position = pos; viewport.push_input(event_motion)

func _send_click(state: bool) -> void: 
	is_mouse_down = state; event_click.position = last_pos; event_click.pressed = state; viewport.push_input(event_click)
