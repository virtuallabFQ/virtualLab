extends Node

var player: PlayerController = null
var game_controller: GameController = null
var ui_context: ContextComponent = null

var player_fov: float = 65.0
var mouse_sensitivity: float = 0.003
var toggle_crouch: bool = false
