@tool
class_name PickUpComponent extends Node

@export var pickup_distance : Vector3 = Vector3(0,0,-1)
@export var pickup_rotation_degrees : Vector3 = Vector3(0, 0, 0)
@export var collision_margin : float = 0.2 
@export var nodes_to_hide_when_picked : Array[Node] = []

var parent
var object : Node3D
var picked_up : bool = false

const pickup_lerp : float = 0.3

func update_state(interactable: Node3D) -> void:
	if not picked_up:
		object = interactable
		if Global.player:
			Global.player.add_collision_exception_with(interactable)
			Global.player.held_object = interactable 
			
		interactable.freeze = true
		picked_up = true
		
		for node in nodes_to_hide_when_picked:
			if node:
				if node is Node3D:
					node.visible = false
				if "disabled" in node:
					node.set_deferred("disabled", true)

func drop_object() -> void:
	if Global.player and object:
		Global.player.remove_collision_exception_with(object)
		Global.player.held_object = null 
	
	for node in nodes_to_hide_when_picked:
		if node:
			if node is Node3D:
				node.visible = true
			if "disabled" in node:
				node.set_deferred("disabled", false)
	
	picked_up = false
	if object:
		object.freeze = false
	object = null

func _input(event: InputEvent) -> void:
	if picked_up and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			drop_object()

func _physics_process(_delta: float) -> void:
	if picked_up and object and Global.player:
		var camera = Global.player.camera
		var camera_transform = camera.global_transform
		var origin = camera.global_position
		
		var target_pos = camera_transform.translated_local(pickup_distance).origin
		var dir_to_target = (target_pos - origin).normalized()
		var check_pos = target_pos + (dir_to_target * collision_margin)
		
		var space_state = object.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, check_pos)
		
		var exclude_rids = []
		if Global.player is CollisionObject3D:
			exclude_rids.append(Global.player.get_rid())
		if object is CollisionObject3D:
			exclude_rids.append(object.get_rid())
		query.exclude = exclude_rids
		
		var result = space_state.intersect_ray(query)
		var final_target_transform = camera_transform
		
		if result:
			var distance_to_wall = origin.distance_to(result.position)
			var safe_distance = max(distance_to_wall - collision_margin, 0.15)
			final_target_transform.origin = origin + (dir_to_target * safe_distance)
		else:
			final_target_transform.origin = target_pos
		
		var rot_rad = Vector3(
			deg_to_rad(pickup_rotation_degrees.x), 
			deg_to_rad(pickup_rotation_degrees.y), 
			deg_to_rad(pickup_rotation_degrees.z)
		)
		final_target_transform.basis = final_target_transform.basis * Basis.from_euler(rot_rad)
		object.global_transform = object.global_transform.interpolate_with(final_target_transform, pickup_lerp)

func _ready() -> void:
	parent = get_parent()
	if parent is InteractionComponent:
		parent.player_interacted.connect(update_state)

func _get_configuration_warnings() -> PackedStringArray:
	if parent is not InteractionComponent:
		return ["This node must have a InteractionComponent parent."]
	else:
		return []

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		parent = get_parent()
		update_configuration_warnings()
