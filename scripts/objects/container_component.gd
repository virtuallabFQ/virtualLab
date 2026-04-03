class_name ContainerComponent extends Node

@export var ghost_mesh: Node3D
@export var interaction_comp: InteractionComponent
@export var interaction_area: Area3D

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
	
	if spatula_comp and not spatula_comp.is_full:
		can_scoop = true
	
	if ghost_mesh: ghost_mesh.visible = can_scoop
	_set_area_enabled(can_scoop)

func _on_scoop(_node: Node) -> void:
	var held = Global.player.held_object
	if held:
		var spatula_comp = held.get_node_or_null("SpatulaComponent")
		if spatula_comp and not spatula_comp.is_full:
			spatula_comp.fill()

func _set_area_enabled(state: bool) -> void:
	if not interaction_area: return
	for i in interaction_area.get_children():
		if i is CollisionShape3D:
			i.set_deferred(&"disabled", not state)
