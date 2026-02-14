extends Node2D

var lines = []
var current_line = []
var is_drawing = false

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
	current_line = [pos]

func add_point(pos: Vector2):
	if is_drawing:
		current_line.append(pos)
		queue_redraw()

func stop_drawing():
	is_drawing = false
	if current_line.size() > 1:
		lines.append(current_line)
	current_line = []
	queue_redraw()
