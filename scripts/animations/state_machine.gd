class_name StateMachine extends Node

@export var current_state: State

var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		states[StringName(child.name)] = child
		child.transition.connect(on_child_transition)
	await owner.ready; current_state.enter(null)

func _process(delta: float) -> void:
	current_state.update(delta)

func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)

func on_child_transition(new_state_name: StringName) -> void:
	var new_state: State = states.get(new_state_name)
	if new_state == current_state: return
	
	current_state.exit()
	var previous_state := current_state
	current_state = new_state
	current_state.enter(previous_state)
