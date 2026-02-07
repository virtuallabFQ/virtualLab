class_name WindowButton extends OptionButton

@export var resolution_button : ResolutionButton

const window_mode_array : Array[String] = [
	"Ecrã Cheio",
	"Janela",
]

func _ready():
	add_window_mode_items()
	self.item_selected.connect(on_window_mode_selected)

func add_window_mode_items() -> void:
	for window_mode in window_mode_array:
		self.add_item(window_mode)

func on_window_mode_selected(index: int) -> void:
	var screen_size = DisplayServer.screen_get_size()
	
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			resolution_button.disabled = false
			DisplayServer.window_set_size(screen_size)
			update_resolution_dropdown_visuals(screen_size)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			resolution_button.disabled = true
			DisplayServer.window_set_size(screen_size)
			update_resolution_dropdown_visuals(screen_size)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			resolution_button.disabled = false
			var target_size = Vector2i(1024, 576)
			DisplayServer.window_set_size(target_size)
			var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
			var window_pos = screen_center - target_size / 2
			DisplayServer.window_set_position(window_pos)
			update_resolution_dropdown_visuals(target_size)
			
func update_resolution_dropdown_visuals(size: Vector2i):
	var expected_text = str(size.x) + "x" + str(size.y) 
	for i in range(resolution_button.item_count):
		var item_text = resolution_button.get_item_text(i)
		if item_text.replace(" ", "") == expected_text:
			resolution_button.selected = i
			return
		
