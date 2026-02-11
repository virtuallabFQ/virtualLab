extends Control

func _ready() -> void:
	MessageBus.toggle_game_paused.connect(on_game_paused)

func on_game_paused(is_paused: bool) -> void:
	visible = not is_paused
