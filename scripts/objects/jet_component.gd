class_name JetComponent extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D

@export var flow_speed: float = 0.1
var is_active: bool = false
var target_recipient: RecipientComponent = null

func _process(delta: float) -> void:
	particles.emitting = is_active
	
	if is_active and is_instance_valid(target_recipient):
		target_recipient.add_liquid(flow_speed * delta)
