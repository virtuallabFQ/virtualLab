extends Node3D
class_name JetComponent

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var raycast: RayCast3D = $RayCast3D

@export var flow_speed: float = 0.1
var is_active: bool = false

func _process(delta: float) -> void:
	particles.emitting = is_active
	
	if is_active and raycast.is_colliding():
		var target = raycast.get_collider()
		
		var recipient = target.get_node_or_null("RecipientComponent")
		if not recipient and target.get_parent():
			recipient = target.get_parent().get_node_or_null("RecipientComponent")
			
		if recipient:
			recipient.add_liquid(flow_speed * delta)
