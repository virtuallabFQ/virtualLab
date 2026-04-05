class_name LiquidPourComponent extends Node

@export var own_recipient: RecipientComponent
@export var requires_snapped: SnapComponent
@export var transfer_rate_ml: float = 7.5

var _target: LiquidTargetComponent

func _ready() -> void:
	_target = get_parent() as LiquidTargetComponent

func _process(_delta: float) -> void:
	if not _target:
		return
	if not _is_snapped():
		if _target.is_ready:
			_target._update_state(false)
		if _target.ghost_mesh:
			_target.ghost_mesh.visible = false

func _physics_process(delta: float) -> void:
	if not _target or not _target.is_filling:
		return
	if not is_instance_valid(_target.snapped_bottle):
		return
	if not own_recipient:
		return
	
	var bottle_recipient := _target.snapped_bottle.get_node_or_null("RecipientComponent") as RecipientComponent
	if not bottle_recipient:
		return
	
	var bottle_fill_ml: float = bottle_recipient.test_fill_volume * bottle_recipient.capacity_ml
	var own_fill_ml: float = own_recipient.test_fill_volume * own_recipient.capacity_ml
	var space_left_ml: float = own_recipient.capacity_ml - own_fill_ml
	
	var amount_ml: float = min(transfer_rate_ml * delta, bottle_fill_ml, space_left_ml)
	if amount_ml <= 0.0:
		return
	
	var new_own_fill_ml := own_fill_ml + amount_ml
	if new_own_fill_ml > 0.0:
		var own_weight := own_fill_ml / new_own_fill_ml
		var bottle_weight := amount_ml / new_own_fill_ml
		var bottle_color: Color = bottle_recipient._target_color
		var own_color: Color = own_recipient._target_color
		var mixed := own_color.lerp(bottle_color, bottle_weight * (1.0 - own_weight * 0.5))
		mixed.a = own_recipient._base_liquid_alpha
		own_recipient._target_color = mixed
		own_recipient._current_color = mixed
		if own_recipient.liquid_mesh:
			own_recipient.liquid_mesh.set_instance_shader_parameter(&"liquid_color", mixed)
	
	bottle_recipient.test_fill_volume -= amount_ml / bottle_recipient.capacity_ml
	own_recipient.add_liquid(amount_ml / own_recipient.capacity_ml)

func _is_snapped() -> bool:
	if not requires_snapped:
		return true
	return requires_snapped.is_snapped
