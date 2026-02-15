class_name Whiteboard extends StaticBody3D

signal focused 
signal unfocused 
signal interacted

@export var draw_layer: MeshInstance3D 
@export var viewport: SubViewport 
@export var canvas_draw: CanvasDraw
@export var board_width := 2.86 
@export var board_height := 1.635

var vp_size: Vector2

func _ready() -> void:
	vp_size = Vector2(viewport.size); viewport.transparent_bg = true
	var mat := StandardMaterial3D.new(); mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; mat.albedo_texture = viewport.get_texture()
	draw_layer.material_override = mat; connect(&"unfocused", canvas_draw.stop_drawing)

func _get_2d(pos: Vector3) -> Vector2:
	var l := to_local(pos); return Vector2((l.x / board_width + 0.5) * vp_size.x, (0.5 - l.y / board_height) * vp_size.y)

func interact_draw(pos: Vector3, pressed: bool, released: bool) -> void: 
	_act(pos, pressed, released, false)

func interact_erase(pos: Vector3, pressed: bool, released: bool) -> void: 
	_act(pos, pressed, released, true)

func _act(pos: Vector3, pressed: bool, released: bool, is_erase: bool) -> void:
	if released: canvas_draw.stop_drawing(); return
	var pos_2d := _get_2d(pos)
	if pressed: canvas_draw.start_stroke(pos_2d, is_erase)
	else: canvas_draw.add_point(pos_2d)
