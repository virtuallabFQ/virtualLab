class_name ResolutionButton extends OptionButton

@export var window_button : WindowButton

var resolutions : Dictionary = {
	"1024x576" : Vector2i(1024, 576),
	"1280x720" : Vector2i(1280, 720),
	"1336x768" : Vector2i(1336, 768),
	"1600x900" : Vector2i(1600, 900),
	"1920x1080" : Vector2i(1920, 1080),
	"2560x1440" : Vector2i(2560, 1440),
	"3840x2160" : Vector2i(3840, 2160)
}

func _ready():
	add_resolutions()
	item_selected.connect(on_resolution_selected)
	var screen_size = DisplayServer.screen_get_size()
	get_window().set_size(screen_size)
	window_button.update_resolution(screen_size)
	
func add_resolutions():
	for r in resolutions:
		add_item(r)

func on_resolution_selected(index: int) -> void:
	var ID = get_item_text(index)
	get_window().set_size(resolutions[ID])
	get_window().move_to_center()
