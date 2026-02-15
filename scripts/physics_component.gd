class_name PhysicsComponent extends Node

@export var controller: CharacterBody3D
@export_range(0, 500, 0.1) var impact_force := 100.0
@export var is_enabled := false

func _physics_process(_delta: float) -> void:
	if not is_enabled or not controller or controller.get_slide_collision_count() == 0: return
	var force := clampf(controller.velocity.length(), 1.0, 10.0) * impact_force
	for i in controller.get_slide_collision_count():
		var hit := controller.get_slide_collision(i); var body := hit.get_collider() as RigidBody3D
		if body: body.apply_impulse(-hit.get_normal() * force, hit.get_position() - body.global_position)
