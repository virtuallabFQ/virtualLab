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
	elif interact_cast_result and interact_cast_result.has_method("interact_ui"):
		interact_cast_result.interact_ui(get_collision_point(), false, false)

func interact_cast() -> void:
	current_cast_result = get_collider()
	var held = Global.player.held_object if Global.player else null
	
	if held and current_cast_result == held:
		current_cast_result = null
	
	if current_cast_result != interact_cast_result:
		if interact_cast_result:
			
			if held: held.propagate_call("cancel_tool", [interact_cast_result])
			
			if interact_cast_result.has_user_signal("unfocused"):
				interact_cast_result.emit_signal("unfocused")
		
		interact_cast_result = current_cast_result
		if interact_cast_result and interact_cast_result.has_user_signal("focused"):
			interact_cast_result.emit_signal("focused")

func interact(is_just_pressed: bool = true, is_released: bool = false) -> void:
	if not interact_cast_result: return
	var held = Global.player.held_object if Global.player else null
	
	if interact_cast_result.has_method("interact_ui"):
		interact_cast_result.interact_ui(get_collision_point(), is_just_pressed, is_released)
	
	elif is_just_pressed and interact_cast_result.has_user_signal("interacted"):
		interact_cast_result.emit_signal("interacted")
	
	if held: 
		held.propagate_call("use_tool", [interact_cast_result, get_collision_point(), get_collision_normal(), is_just_pressed, is_released])
