extends OptionButton

const window_mode_array : Array[String] = [
	"Ecrã Cheio",
	"Janela sem margens",
	"Janela",
]

func _ready():
	add_window_mode_items()
	self.item_selected.connect(on_window_mode_selected)

func add_window_mode_items() -> void:
	for window_mode in window_mode_array:
		self.add_item(window_mode)

func on_window_mode_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
