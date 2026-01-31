class_name MovementState

extends State

var player: PlayerController
var animation: AnimationPlayer

func _ready() -> void:
	await owner.ready
	player = owner as PlayerController
	animation = player.animation_player

func _process(_delta: float) -> void:
	pass
