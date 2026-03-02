@tool
extends Node3D

const oceantile := preload("res://scenes/objects/s_ocean_mesh.tscn")
const oceangrid := preload("res://resources/oceangrid_info.tres")
const tile_size := 10.05 

var mesh_cache: Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		for child in get_children():
			child.queue_free()
	
	var pts: Array[Vector2] = oceangrid.spawnPoints
	var subs: Array[int] = oceangrid.subdivision
	var scales: Array[int] = oceangrid.scale
	
	for i in pts.size():
		var tile := oceantile.instantiate() as MeshInstance3D
		add_child(tile)
		
		tile.position = Vector3(pts[i].x, 0.0, pts[i].y) * tile_size
		tile.scale = Vector3(scales[i], 1.0, scales[i])
		
		var target_sub := subs[i]
		if mesh_cache.has(target_sub):
			tile.mesh = mesh_cache[target_sub]
		else:
			tile.mesh = tile.mesh.duplicate()
			tile.mesh.subdivide_width = target_sub
			tile.mesh.subdivide_depth = target_sub
			mesh_cache[target_sub] = tile.mesh

func _process(_delta: float) -> void:
	RenderingServer.global_shader_parameter_set("ocean_pos", global_position)
