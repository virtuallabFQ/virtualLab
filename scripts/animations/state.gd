class_name State extends Node

@warning_ignore("unused_signal")
signal transition(new_state_name: StringName)

func _ready() -> void:
	set_process(false)
	set_physics_process(false)

func enter(_previous_state: State = null) -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
