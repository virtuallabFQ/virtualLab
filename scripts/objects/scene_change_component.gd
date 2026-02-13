class_name SceneChangeComponent extends Node

@export var interaction_component: InteractionComponent
@export_file("*.tscn") var target_scene_path: String

func _ready() -> void:
	interaction_component.player_interacted.connect(on_interact)
	
func on_interact(_body) -> void:
	Global.game_controller.change_gui_scene(target_scene_path)
