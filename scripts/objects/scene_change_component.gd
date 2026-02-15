class_name SceneChangeComponent extends Node

@export var interact_component: InteractionComponent
@export_file("*.tscn") var scene_path: String

func _ready() -> void:
	interact_component.player_interacted.connect(func(_target): Global.game_controller.change_gui_scene(scene_path))
