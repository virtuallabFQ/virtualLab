class_name PhysicsComponent extends Node

@export var controller: CharacterBody3D
@export_range(0.0, 500.0, 0.1) var impact_force: float = 100.0
@export var is_enabled: bool = false

func _physics_process(_delta: float) -> void:
	if not is_enabled or not is_instance_valid(controller): 
		return
	var _total_impulse_strength: float = clamp(controller.velocity.length(), 1.0, 10.0) * impact_force
	for i in range(controller.get_slide_collision_count()):
		var _collision: KinematicCollision3D = controller.get_slide_collision(i)
		var _rigid_body: RigidBody3D = _collision.get_collider() as RigidBody3D
		
		if is_instance_valid(_rigid_body): 
			_rigid_body.apply_impulse(-_collision.get_normal() * _total_impulse_strength, _collision.get_position() - _rigid_body.global_position)
