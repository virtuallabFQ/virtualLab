class_name CrouchingButton extends Button

func _ready() -> void:
	update_button_text()
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	Global.toggle_crouch = !Global.toggle_crouch
	if Global.player:
		Global.player.toggle_crouch = Global.toggle_crouch
	update_button_text()

func update_button_text() -> void:
	text = "Alternar" if Global.toggle_crouch else "Segurar"
