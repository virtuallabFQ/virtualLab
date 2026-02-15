extends Node2D

var lines: Array[PackedVector2Array] = []
var current_line: PackedVector2Array = PackedVector2Array()
var current_eraser_line : Line2D

var is_drawing = false
var is_erasing = false

var brush_color = Color.BLACK
var brush_size = 6.0

func _draw():
	for line in lines:
		if line.size() > 1:
			draw_polyline(line, brush_color, brush_size, true)
	
	if current_line.size() > 1:
		draw_polyline(current_line, brush_color, brush_size, true)

func start_drawing(pos: Vector2):
	is_drawing = true
	is_erasing = false
	current_line = [pos]

func start_erasing(pos: Vector2):
	is_erasing = true
	is_drawing = false
	
	current_eraser_line = Line2D.new()
	current_eraser_line.width = brush_size * 8.0 
	current_eraser_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	current_eraser_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	current_eraser_line.joint_mode = Line2D.LINE_JOINT_ROUND
	current_eraser_line.antialiased = true
	
	var eraser_mat = CanvasItemMaterial.new()
	eraser_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
	current_eraser_line.material = eraser_mat
	current_eraser_line.default_color = Color.WHITE 
	
	add_child(current_eraser_line)
	current_eraser_line.add_point(pos)

func add_point(pos: Vector2):
	if is_drawing:
		current_line.append(pos)
		queue_redraw()
	elif is_erasing and current_eraser_line:
		current_eraser_line.add_point(pos)

func stop_drawing():
	if is_drawing:
		if current_line.size() > 1:
			lines.append(current_line)
		current_line = []
		
	is_drawing = false
	is_erasing = false
	current_eraser_line = null
	queue_redraw()
