class_name PowderPourComponent extends Node

@export var target_rigidbody: RigidBody3D
@export var ghost_mesh: Node3D
@export var interaction_comp: InteractionComponent
@export var interaction_area: Area3D
@export var mass_per_scoop: float = 0.0005

@export_group("Powder Visuals")
@export var powder_visual_pivot: Node3D
@export var scale_per_scoop: float = 0.1

func _ready() -> void:
	if ghost_mesh: ghost_mesh.visible = false
	
	if powder_visual_pivot:
		powder_visual_pivot.visible = false
		powder_visual_pivot.scale.y = 0.001
		
	_set_area_enabled(false)
	if interaction_comp: interaction_comp.player_interacted.connect(_on_pour)

func _process(_delta: float) -> void:
	var player := Global.player
	if not player or not player.held_object:
		if ghost_mesh: ghost_mesh.visible = false
		_set_area_enabled(false)
		return
		
	var held = player.held_object
	var can_pour = false
	
	var spatula_comp = held.get_node_or_null("SpatulaComponent")
	
	if spatula_comp and spatula_comp.is_full:
		can_pour = true
		
	if ghost_mesh: ghost_mesh.visible = can_pour
	_set_area_enabled(can_pour)

func _on_pour(_node: Node) -> void:
	var held = Global.player.held_object
	if held:
		var spatula_comp = held.get_node_or_null("SpatulaComponent")
		if spatula_comp and spatula_comp.is_full:
			spatula_comp.empty()
			
			if target_rigidbody:
				target_rigidbody.mass += mass_per_scoop
			
			if powder_visual_pivot:
				if not powder_visual_pivot.visible:
					powder_visual_pivot.visible = true
				
				powder_visual_pivot.scale.y += scale_per_scoop
			
			if ghost_mesh: ghost_mesh.visible = false

func _set_area_enabled(state: bool) -> void:
	if not interaction_area: return
	for i in interaction_area.get_children():
		if i is CollisionShape3D:
			i.set_deferred(&"disabled", not state)
