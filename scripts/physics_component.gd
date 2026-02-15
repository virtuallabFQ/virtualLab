class_name PhysicsComponent extends Node

@export var controller : CharacterBody3D
@export_range(0.0, 500.0, 0.1) var force : float = 100.0
@export var enabled : bool = false

func _physics_process(_delta: float) -> void:
	if not enabled or controller.get_slide_collision_count() == 0:
		return
	for i in controller.get_slide_collision_count():
		var collision = controller.get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			var direction = -collision.get_normal()
			var speed = clamp(controller.velocity.length(), 1.0, 10.0)
			var impulse_pos = collision.get_position() - collider.global_position
			collider.apply_impulse(direction * speed * force, impulse_pos)
