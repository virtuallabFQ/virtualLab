class_name WindowButton extends OptionButton

@export var resolution_button : ResolutionButton

var window_mode_array : Array[String] = [
	"Ecrã Cheio",
	"Janela",
]

func _ready():
	add_window_mode_items()
	item_selected.connect(on_window_mode_selected)

func add_window_mode_items() -> void:
	for w in window_mode_array:
		add_item(w)

func on_window_mode_selected(index: int) -> void:
	match index:
		0:
			get_window().set_mode(Window.MODE_FULLSCREEN)
			resolution_button.disabled = false
			var screen_size = DisplayServer.screen_get_size()
			get_window().set_size(screen_size)
			update_resolution(screen_size)
		1:
			get_window().set_mode(Window.MODE_WINDOWED)
			resolution_button.disabled = false
			var target_size = Vector2i(1024, 576)
			get_window().set_size(target_size)
			update_resolution(target_size)
			get_window().move_to_center()
			
func update_resolution(size: Vector2i):
	var expected_text = str(size.x) + "x" + str(size.y) 
	for i in range(resolution_button.item_count):
		var item_text = resolution_button.get_item_text(i)
		if item_text.replace(" ", "") == expected_text:
			resolution_button.selected = i
			return
		
