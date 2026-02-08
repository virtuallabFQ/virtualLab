extends Label

func _ready():
	add_to_group("FPS_DISPLAY_GROUP")
	update_visibility(ShowButton.show_fps_enabled)

func _process(_delta):
	text = str(int(Engine.get_frames_per_second())) + " FPS"

func update_visibility(state: bool) -> void:
	visible = state
	set_process(state)
