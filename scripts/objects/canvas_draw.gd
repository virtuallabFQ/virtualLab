class_name CanvasDraw extends Node2D

var line: Line2D 
var last: Vector2 
var mat := CanvasItemMaterial.new()

func _ready():
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
	
func stop_drawing():
	line = null

func add_point(pos: Vector2): 
	if line and pos.distance_squared_to(last) > 16: line.add_point(pos); last = pos

func start_stroke(pos: Vector2, erase: bool):
	line = Line2D.new(); add_child(line); line.add_point(pos); last = pos; if erase: line.material = mat
	line.width = 85 if erase else 8; line.default_color = Color.WHITE if erase else Color.BLACK
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND; line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND; line.round_precision = 24
