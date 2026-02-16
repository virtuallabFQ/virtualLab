class_name CanvasDraw extends Node2D

@export var brush_size := 8.0
@export var brush_color := Color.BLACK
@export var eraser_size := 85.0
@export var min_step_sq := 16.0

var current_line: Line2D
var last_pos: Vector2
var eraser_mat := CanvasItemMaterial.new()

func _ready() -> void:
	eraser_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB

func stop_drawing() -> void:
	current_line = null

func add_point(pos: Vector2) -> void: 
	if current_line and pos.distance_squared_to(last_pos) > min_step_sq:
		current_line.add_point(pos); last_pos = pos

func start_stroke(pos: Vector2, is_erase: bool) -> void:
	current_line = Line2D.new(); current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	current_line.end_cap_mode = Line2D.LINE_CAP_ROUND; current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	current_line.round_precision = 24; current_line.width = eraser_size if is_erase else brush_size
	current_line.default_color = Color.WHITE if is_erase else brush_color
	if is_erase: current_line.material = eraser_mat
	add_child(current_line); current_line.add_point(pos); last_pos = pos
