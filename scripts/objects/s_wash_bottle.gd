extends RigidBody3D

@onready var water_stream_cast: ShapeCast3D = $ShapeCast3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@export var liquid_material: Material 

var is_pouring := true

func _physics_process(delta: float) -> void:
	# (A tua lógica do rato/teclado para saber se está a verter)
	# is_pouring = ... 
	
	particles.emitting = is_pouring
	
	if is_pouring:
		# Obriga o motor de física a atualizar a posição da esfera neste exato milissegundo
		water_stream_cast.force_shapecast_update() 
		
		if water_stream_cast.is_colliding():
			# Pega no PRIMEIRO objeto em que a água bateu (índice 0)
			var hit_object = water_stream_cast.get_collider(0)
			
			if hit_object is Area3D and hit_object.name == "LiquidReceiverArea":
				var beaker_root = hit_object.get_parent()
				var recipient = beaker_root.get_node_or_null("RecipientComponent")
				
				if recipient:
					# Chama o componente e enche o copo com o tempo delta!
					recipient.receive_liquid(delta, liquid_material)
