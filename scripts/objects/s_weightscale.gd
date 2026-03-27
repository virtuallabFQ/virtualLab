extends RigidBody3D

@onready var menu: Control = $SubViewport/weightscale_menu
@onready var component: WeightscaleComponent = $WeightscaleComponent

var is_on: bool = false
var tare_offset: float = 0.0

func _ready():
	await RenderingServer.frame_post_draw
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	component.weight_changed.connect(_on_weight_changed)
	
	if menu and menu.has_method("turn_off"):
		menu.turn_off()

func _on_weight_changed(grams: float):
	if is_on:
		var final_weight = max(0.0, grams - tare_offset)
		menu.set_weight(final_weight)

func press_on_tare():
	if not is_on:
		is_on = true
		tare_offset = 0.0
		menu.turn_on()
		
		var current_grams = component.get_weight()
		menu.set_weight(max(0.0, current_grams))
	else:
		tare_offset = component.get_weight()
		menu.set_weight(0.0)

func press_off():
	if is_on:
		is_on = false
		tare_offset = 0.0
		menu.turn_off()

func _on_interaction_component_1_player_interacted(object: Node) -> void:
	press_on_tare()

func _on_interaction_component_2_player_interacted(object: Node) -> void:
	press_off()
