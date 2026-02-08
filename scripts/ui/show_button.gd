class_name ShowButton extends Button

static var show_fps_enabled : bool = false

func _ready():
	update_button_text()
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	show_fps_enabled = !show_fps_enabled
	update_button_text()
	get_tree().call_group("FPS_DISPLAY_GROUP", "update_visibility", show_fps_enabled)

func update_button_text() -> void:
	if show_fps_enabled:
		text = "Ligado"
	else:
		text = "Desligado"
