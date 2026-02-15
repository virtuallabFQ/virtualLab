extends Node2D

var current_line_node: Line2D # Variável única para a linha atual (seja caneta ou borracha)

var is_drawing = false
var is_erasing = false

var brush_color = Color.BLACK
var brush_size = 6.0

# Removemos a função _draw() antiga porque causava o problema de camadas
func _draw():
	pass

func start_drawing(pos: Vector2):
	stop_drawing() # Fecha qualquer linha anterior
	
	is_drawing = true
	is_erasing = false
	
	# AGORA A CANETA CRIA UM NÓ REAL, tal como o apagador
	current_line_node = Line2D.new()
	current_line_node.width = brush_size
	current_line_node.default_color = brush_color
	
	# Deixar as pontas redondinhas para ficar bonito
	current_line_node.begin_cap_mode = Line2D.LINE_CAP_ROUND
	current_line_node.end_cap_mode = Line2D.LINE_CAP_ROUND
	current_line_node.joint_mode = Line2D.LINE_JOINT_ROUND
	current_line_node.antialiased = true
	
	add_child(current_line_node)
	current_line_node.add_point(pos)

func start_erasing(pos: Vector2):
	stop_drawing()
	
	is_erasing = true
	is_drawing = false
	
	current_line_node = Line2D.new()
	current_line_node.width = brush_size * 12.0 # Borracha maior que a caneta
	
	current_line_node.begin_cap_mode = Line2D.LINE_CAP_ROUND
	current_line_node.end_cap_mode = Line2D.LINE_CAP_ROUND
	current_line_node.joint_mode = Line2D.LINE_JOINT_ROUND
	current_line_node.antialiased = true
	
	# Material de "Subtração" para apagar
	var eraser_mat = CanvasItemMaterial.new()
	eraser_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
	current_line_node.material = eraser_mat
	
	# Nota: No modo SUB, a cor branca significa "apagar 100%"
	current_line_node.default_color = Color(1, 1, 1, 1) 
	
	add_child(current_line_node)
	current_line_node.add_point(pos)

func add_point(pos: Vector2):
	# Agora usamos a mesma lógica para ambos
	if (is_drawing or is_erasing) and is_instance_valid(current_line_node):
		current_line_node.add_point(pos)

func stop_drawing():
	is_drawing = false
	is_erasing = false
	current_line_node = null
