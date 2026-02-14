extends StaticBody3D

@onready var canvas_draw = $SubViewport/CanvasDraw
@onready var viewport = $SubViewport
@onready var draw_layer = $DrawLayer

@export var board_width: float = 2.86
@export var board_height: float = 1.635

func _ready():
	viewport.transparent_bg = true
	var paint_material = StandardMaterial3D.new()
	paint_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	paint_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	paint_material.albedo_texture = viewport.get_texture()
	draw_layer.material_override = paint_material

func _get_2d_pos(hit_position_global: Vector3) -> Vector2:
	var local_hit = to_local(hit_position_global)
	var mapped_x = ((local_hit.x / board_width) + 0.5) * viewport.size.x
	var mapped_y = (0.5 - (local_hit.y / board_height)) * viewport.size.y
	return Vector2(mapped_x, mapped_y)

func interact_draw(hit_position_global: Vector3, is_just_pressed: bool, is_released: bool):
	if is_released:
		canvas_draw.stop_drawing()
		return
	
	var pos_2d = _get_2d_pos(hit_position_global)
	if is_just_pressed:
		canvas_draw.start_drawing(pos_2d)
	else:
		canvas_draw.add_point(pos_2d)

func interact_erase(hit_position_global: Vector3, is_just_pressed: bool, is_released: bool):
	if is_released:
		canvas_draw.stop_drawing()
		return
		
	var pos_2d = _get_2d_pos(hit_position_global)
	if is_just_pressed:
		canvas_draw.start_erasing(pos_2d)
	else:
		canvas_draw.add_point(pos_2d)
