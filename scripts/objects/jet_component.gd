class_name JetComponent extends Node3D
 
@onready var particles: GPUParticles3D = $GPUParticles3D
 
@export var flow_speed: float = 0.1
@export var flow_axis: Vector3 = Vector3(1, 0, 0)
 
var is_active: bool = false
var target_recipient: RecipientComponent = null
 
func _process(delta: float) -> void:
	particles.emitting = is_active
	
	if is_active and is_instance_valid(target_recipient):
		var target_pos := (target_recipient.get_parent() as Node3D).global_position
		var my_pos := global_position
		
		var dir := (target_pos - my_pos).normalized()
		var local_dir := particles.global_transform.basis.inverse() * dir
		particles.process_material.set("direction", local_dir)
		
		var dist_horizontal := Vector2(
			target_pos.x - my_pos.x,
			target_pos.z - my_pos.z
		).length()
		var dist_vertical := maxf(my_pos.y - target_pos.y, 0.0)
		
		var mat := particles.process_material as ParticleProcessMaterial
		if mat:
			var vel := (mat.initial_velocity_min + mat.initial_velocity_max) / 2.0
			if vel > 0.0:
				particles.lifetime = clamp((dist_horizontal / vel) + (dist_vertical * 0.01), 0.1, 2.0)
		
		target_recipient.add_liquid(flow_speed * delta)
	elif is_active:
		var dir := global_transform.basis * flow_axis
		particles.process_material.set("direction", dir)
