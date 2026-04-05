class_name ContainerComponent extends Node

@export var ghost_mesh: Node3D
@export var interaction_comp: InteractionComponent
@export var interaction_area: Area3D
@export var lid_component: LidComponent
@export var scoop_mass_kg: float = 0.0005 

func _ready() -> void:
	if ghost_mesh: ghost_mesh.visible = false
	_set_area_enabled(false)
	if interaction_comp: interaction_comp.player_interacted.connect(_on_scoop)

func _process(_delta: float) -> void:
	var player := Global.player
	if not player or not player.held_object:
		if ghost_mesh: ghost_mesh.visible = false
		_set_area_enabled(false)
		return
		
	var held = player.held_object
	var can_scoop = false
	var spatula_comp = held.get_node_or_null("SpatulaComponent") 
	
	var lid_is_open = not lid_component or not lid_component.is_closed
	if spatula_comp and not spatula_comp.is_full and lid_is_open:
		can_scoop = true
	
	if ghost_mesh: ghost_mesh.visible = can_scoop
	_set_area_enabled(can_scoop)

func _on_scoop(_node: Node) -> void:
	var held = Global.player.held_object
	if held:
		var spatula_comp = held.get_node_or_null("SpatulaComponent")
		var lid_is_open = not lid_component or not lid_component.is_closed
		if spatula_comp and not spatula_comp.is_full and lid_is_open:
			spatula_comp.fill()
			
			var rb := get_parent() as RigidBody3D
			if rb:
				rb.mass = max(rb.mass - scoop_mass_kg, 0.010)

func _set_area_enabled(state: bool) -> void:
	if not interaction_area: return
	for i in interaction_area.get_children():
		if i is CollisionShape3D:
			i.set_deferred(&"disabled", not state)
