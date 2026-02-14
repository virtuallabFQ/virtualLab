extends RayCast3D

var interact_cast_result
var current_cast_result
var is_holding_interact = false

func _input(event):
	if event.is_action_pressed("interact"):
		is_holding_interact = true
		interact(true, false)
	elif event.is_action_released("interact"):
		is_holding_interact = false
		interact(false, true)
		
func _physics_process(_delta: float) -> void:
	interact_cast()
	
	if is_holding_interact:
		interact(false, false)
	else:
		if interact_cast_result and interact_cast_result.has_method("interact_ui"):
			interact_cast_result.interact_ui(get_collision_point(), false, false)

func interact_cast() -> void:
	current_cast_result = get_collider()
	
	if Global.player and Global.player.held_object != null and current_cast_result == Global.player.held_object:
		current_cast_result = null
	
	if current_cast_result != interact_cast_result:
		if interact_cast_result:
			if is_holding_interact and interact_cast_result.has_method("interact_draw"):
				interact_cast_result.interact_draw(Vector3.ZERO, false, true)
			elif is_holding_interact and interact_cast_result.has_method("interact_ui"):
				interact_cast_result.interact_ui(Vector3.ZERO, false, true)
			
			if interact_cast_result.has_method("clear_hover"):
				interact_cast_result.clear_hover()
				
			if interact_cast_result.has_user_signal("unfocused"):
				interact_cast_result.emit_signal("unfocused")
		interact_cast_result = current_cast_result
		
		if interact_cast_result and interact_cast_result.has_user_signal("focused"):
			interact_cast_result.emit_signal("focused")

func interact(is_just_pressed: bool = true, is_released: bool = false) -> void:
	if interact_cast_result:
		if interact_cast_result.has_method("interact_ui"):
			interact_cast_result.interact_ui(get_collision_point(), is_just_pressed, is_released)
			
		elif interact_cast_result.has_method("interact_draw"):
			var is_holding_marker = false
			if Global.player and Global.player.held_object != null:
				if "marker" in Global.player.held_object.name.to_lower():
					is_holding_marker = true
			if is_holding_marker:
				interact_cast_result.interact_draw(get_collision_point(), is_just_pressed, is_released)
			elif is_released:
				interact_cast_result.interact_draw(Vector3.ZERO, false, true)
		
		elif is_just_pressed and interact_cast_result.has_user_signal("interacted"):
			interact_cast_result.emit_signal("interacted")
