class_name VSyncButton extends Button

func _ready():
	update_state()
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var current_mode = DisplayServer.window_get_vsync_mode()
	if current_mode == DisplayServer.VSYNC_DISABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	update_state()

func update_state() -> void:
	var mode = DisplayServer.window_get_vsync_mode()
	if mode == DisplayServer.VSYNC_DISABLED:
		text = "Desligado"
	else:
		text = "Ligado"
