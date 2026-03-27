class_name SittingState extends State

var target_pos: Vector3
var target_rot_y: float
var pre_sit_position: Vector3
var stand_up_callback: Callable 

var is_animating := false
var player: PlayerController

func start_sitting(pos: Vector3, rot_y: float, callback: Callable) -> void:
	player = Global.player
	target_pos = pos
	target_rot_y = rot_y
	stand_up_callback = callback
	transition.emit(&"SittingState")

func enter(_prev: State = null) -> void:
	is_animating = true
	pre_sit_position = player.global_position 
	
	player.velocity = Vector3.ZERO
	player.collider.set_deferred("disabled", true)
	
	var tween = create_tween()
	
	tween.set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(player, "global_position:x", target_pos.x, 0.4)
	tween.tween_property(player, "global_position:z", target_pos.z, 0.4)
	
	tween.chain().tween_property(player, "global_position:y", target_pos.y - 0.08, 0.4).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_property(player, "global_position:y", target_pos.y, 0.2).set_trans(Tween.TRANS_QUAD)
	
	tween.chain().tween_callback(func(): is_animating = false)

func exit() -> void:
	is_animating = false
	player.collider.set_deferred("disabled", false)
	if stand_up_callback.is_valid(): 
		stand_up_callback.call()

func update(_delta: float) -> void:
	if Input.is_action_just_pressed(&"jump"):
		get_viewport().set_input_as_handled()
		
		if not is_animating:
			stand_up()

func stand_up() -> void:
	is_animating = true
	var tween = create_tween()
	
	tween.tween_property(player, "global_position:y", pre_sit_position.y, 0.4).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_property(player, "global_position:x", pre_sit_position.x, 0.4)
	tween.parallel().tween_property(player, "global_position:z", pre_sit_position.z, 0.4)
	
	tween.chain().tween_callback(func():
		transition.emit(&"IdleState")
	)
