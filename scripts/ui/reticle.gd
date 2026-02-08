extends CenterContainer

@export var DOT_RADIUS : float = 3.0 
@export var DOT_COLOR : Color = Color.WHITE

@export var OUTLINE_WIDTH : float = 2.0 
@export var OUTLINE_COLOR : Color = Color.BLACK

func _ready() -> void:
	queue_redraw()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw():
	var center_pos = size / 2
	
	draw_circle(center_pos, DOT_RADIUS + OUTLINE_WIDTH, OUTLINE_COLOR)
	
	draw_circle(center_pos, DOT_RADIUS, DOT_COLOR)
