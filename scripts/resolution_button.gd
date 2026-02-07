extends OptionButton

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

func add_screen_resolution_items() -> void:
	for screen_resolution in screen_resolution_dictionary:
		self.add_item(screen_resolution)

func on_screen_resolution_selected(_index: int) -> void:
	DisplayServer.window_set_size(screen_resolution_dictionary.values()[_index])
