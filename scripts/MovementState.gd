class_name MovementState

extends State

var player: CharacterBody3D
var animation: AnimationPlayer

func _ready() -> void:
	await owner.ready
	player = owner as CharacterBody3D
	animation = player.animation_player

func _process(_delta: float) -> void:
	pass
