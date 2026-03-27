class_name WeightscaleComponent extends Node

signal weight_changed(grams: float)

@export var detector_path: NodePath
@onready var detector: Area3D = get_node(detector_path)

var bodies_in_scale: Array[RigidBody3D] = []
var current_total_weight: float = -1.0 

func _ready():
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)

func _process(_delta: float):
	_calculate_and_emit()

func _on_body_entered(body: Node):
	if body is RigidBody3D and body != get_parent():
		if not bodies_in_scale.has(body):
			bodies_in_scale.append(body)

func _on_body_exited(body: Node):
	if body is RigidBody3D:
		bodies_in_scale.erase(body)

func _calculate_and_emit():
	var total = 0.0
	
	bodies_in_scale = bodies_in_scale.filter(func(b): return is_instance_valid(b))
	
	for body in bodies_in_scale:
		if not _is_body_held(body):
			total += body.mass * 1000.0
	
	if total != current_total_weight:
		current_total_weight = total
		weight_changed.emit(total)

func get_weight() -> float:
	return current_total_weight

func _is_body_held(body: RigidBody3D) -> bool:
	return body.freeze
