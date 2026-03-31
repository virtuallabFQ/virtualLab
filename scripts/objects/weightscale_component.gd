class_name WeightscaleComponent extends Node

@export var detector: Area3D
@export var on_button: InteractionComponent
@export var off_button: InteractionComponent
@export var menu: Control
@export var viewport: SubViewport

var bodies_in_scale: Array[RigidBody3D] = []
var is_active: bool = false
var tare_offset_grams: float = 0.0
var raw_weight_grams: float = 0.0
var last_sent_weight: float = -1.0

func _ready() -> void:
	if viewport: viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	if detector:
		detector.body_entered.connect(func(body): 
			if body is RigidBody3D and body != get_parent(): bodies_in_scale.append(body))
		detector.body_exited.connect(func(body): 
			if body is RigidBody3D: bodies_in_scale.erase(body))
	if menu: menu.turn_off()

func _physics_process(_delta: float) -> void:
	if on_button and on_button.is_interacted:
		on_button.is_interacted = false
		if not is_active:
			is_active = true
			if menu: menu.turn_on()
		else: tare_offset_grams = raw_weight_grams
		last_sent_weight = -1.0
	
	if off_button and off_button.is_interacted:
		off_button.is_interacted = false
		is_active = false
		tare_offset_grams = 0.0
		last_sent_weight = -1.0
		if menu: menu.turn_off()
	
	if bodies_in_scale.is_empty() and raw_weight_grams == 0.0 and last_sent_weight == 0.0: return
	
	var mass: float = 0.0
	var body_index: int = bodies_in_scale.size() - 1
	while body_index >= 0:
		var body = bodies_in_scale[body_index]
		if not is_instance_valid(body): bodies_in_scale.remove_at(body_index)
		elif not body.freeze: mass += body.mass
		body_index -= 1

	raw_weight_grams = mass * 1000.0
	var display = raw_weight_grams - tare_offset_grams
	if is_active and menu and not is_equal_approx(display, last_sent_weight):
		last_sent_weight = display
		menu.set_weight(display)
