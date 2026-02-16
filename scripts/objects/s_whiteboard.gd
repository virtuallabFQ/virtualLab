class_name Whiteboard extends StaticBody3D

@warning_ignore("unused_signal")
signal focused
@warning_ignore("unused_signal")
signal unfocused
@warning_ignore("unused_signal")
signal interacted

@export var draw_layer: MeshInstance3D 
@export var viewport: SubViewport 
@export var canvas_draw: CanvasDraw
@export var board_width := 2.86 
@export var board_height := 1.635

var ratio_x := 0.0 
var ratio_y := 0.0 
var center_x := 0.0 
var center_y := 0.0

var half_width := 0.0
var half_height := 0.0

func _ready() -> void:
	viewport.transparent_bg = true
	connect(&"unfocused", canvas_draw.stop_drawing)
	
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = viewport.get_texture()
	draw_layer.material_override = mat 
	
	ratio_x = viewport.size.x / board_width
	ratio_y = viewport.size.y / board_height
	center_x = viewport.size.x * 0.5
	center_y = viewport.size.y * 0.5
	
	half_width = board_width * 0.5
	half_height = board_height * 0.5

func _get_2d(hit_pos: Vector3) -> Vector2:
	var local_pos := to_local(hit_pos)
	return Vector2(local_pos.x * ratio_x + center_x, center_y - local_pos.y * ratio_y)

func _action(hit_pos: Vector3, pressed: bool, released: bool, erase: bool) -> void:
	if released: canvas_draw.stop_drawing()
	elif pressed: canvas_draw.start_stroke(_get_2d(hit_pos), erase)
	else: canvas_draw.add_point(_get_2d(hit_pos))

func interact_draw(hit_pos: Vector3, pressed: bool, released: bool) -> void:
	_action(hit_pos, pressed, released, false)

func interact_erase(hit_pos: Vector3, pressed: bool, released: bool) -> void:
	_action(hit_pos, pressed, released, true)

func clamp_position(global_pos: Vector3, extents: Vector2) -> Vector3:
	var local_pos := to_local(global_pos)
	var limit_x := half_width - extents.x
	var limit_y := half_height - extents.y
	return to_global(local_pos.clamp(Vector3(-limit_x, -limit_y, local_pos.z), Vector3(limit_x, limit_y, local_pos.z)))
