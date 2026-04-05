class_name WeightscaleComponent extends Node

@export var detector: Area3D
@export var on_button: InteractionComponent
@export var off_button: InteractionComponent
@export var menu: Control
@export var viewport: SubViewport

var is_active: bool = false
var tare_offset_grams: float = 0.0
var raw_weight_grams: float = 0.0
var last_sent_weight: float = -1.0

func _ready() -> void:
	if viewport: viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
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
	
	var mass: float = 0.0
	var counted_ids: Dictionary = {}
	
	if detector:
		for body in detector.get_overlapping_bodies():
			if body is RigidBody3D and body != get_parent():
				
				if body.linear_velocity.length() < 1.0 and not body.freeze:
					var id: int = body.get_instance_id()
					if not counted_ids.has(id):
						counted_ids[id] = true
						mass += body.mass
				
				var lid_comp := body.find_child("LidComponent", true, false) as LidComponent
				
				if not lid_comp and body.get_parent():
					var temp_lid = body.get_parent().find_child("LidComponent", true, false) as LidComponent
					if temp_lid and (temp_lid.target_body == body or temp_lid.target_body == body.get_parent()):
						lid_comp = temp_lid
				
				if lid_comp and lid_comp.is_closed and lid_comp.lid_node:
					var lid_id: int = lid_comp.lid_node.get_instance_id()
					if not counted_ids.has(lid_id):
						counted_ids[lid_id] = true
						mass += lid_comp.lid_node.mass
	
	raw_weight_grams = mass * 1000.0
	var display = raw_weight_grams - tare_offset_grams
	
	if is_active and menu and not is_equal_approx(display, last_sent_weight):
		last_sent_weight = display
		menu.set_weight(display)
