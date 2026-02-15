extends Label

func _ready():
	add_to_group("FPS_DISPLAY_GROUP")
	update_visibility(ShowButton.show_fps_enabled)

func _process(_delta):
	text = "%d FPS" % Engine.get_frames_per_second()

func update_visibility(state: bool) -> void:
	visible = state
	set_process(state)
