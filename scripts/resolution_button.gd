class_name ResolutionButton extends OptionButton

@export var window_button : WindowButton

const screen_resolution_dictionary : Dictionary = {
	"1024x576" : Vector2i(1024, 576),
	"1280x720" : Vector2i(1280, 720),
	"1336x768" : Vector2i(1336, 768),
	"1600x900" : Vector2i(1600, 900),
	"1920x1080" : Vector2i(1920, 1080),
	"2560x1440" : Vector2i(2560, 1440),
	"3840x2160" : Vector2i(3840, 2160)
}

func _ready():
	add_screen_resolution_items()
	self.item_selected.connect(on_screen_resolution_selected)
	var screen_size = DisplayServer.screen_get_size()
	DisplayServer.window_set_size(screen_size)
	get_window().content_scale_size = screen_size
	window_button.update_resolution_dropdown_visuals(screen_size)

func add_screen_resolution_items() -> void:
	for screen_resolution in screen_resolution_dictionary:
		self.add_item(screen_resolution)

func on_screen_resolution_selected(_index: int) -> void:
	var selected_text = get_item_text(_index)
	var size = screen_resolution_dictionary[selected_text]
	apply_resolution(size)
	
func apply_resolution(size: Vector2i) -> void:
	var current_mode = DisplayServer.window_get_mode()
	get_window().content_scale_size = size
	
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(size)
		var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
		var window_pos = screen_center - size / 2
		DisplayServer.window_set_position(window_pos)
