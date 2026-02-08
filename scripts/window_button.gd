class_name WindowButton extends OptionButton

@export var resolution_button : ResolutionButton
@onready var scaling_button = get_node("../scaling_button")

var window_mode_array : Array[String] = [
	"Ecrã Cheio",
	"Janela",
]

func check_variables():
	var window = get_window()
	var mode = window.get_mode()

	if mode == Window.MODE_FULLSCREEN:
		selected = 0
		resolution_button.disabled = true
	elif mode == Window.MODE_WINDOWED:
		selected = 1
		resolution_button.disabled = false

func _ready():
	add_window_mode_items()
	check_variables()
	item_selected.connect(on_window_mode_selected)

func add_window_mode_items() -> void:
	for w in window_mode_array:
		add_item(w)

func on_window_mode_selected(index: int) -> void:
	match index:
		0:
			get_window().set_mode(Window.MODE_FULLSCREEN)
			resolution_button.disabled = true
			var screen_size = DisplayServer.screen_get_size()
			get_window().set_size(screen_size)
			update_resolution(screen_size)
			scaling_button.reset_scaling_to_max()
		1:
			get_window().set_mode(Window.MODE_WINDOWED)
			resolution_button.disabled = false
			var target_size = Vector2i(1024, 576)
			get_window().set_size(target_size)
			update_resolution(target_size)
			scaling_button.reset_scaling_to_max()
			get_window().move_to_center()
			
func update_resolution(size: Vector2i):
	var expected_text = str(size.x) + "x" + str(size.y) 
	for i in range(resolution_button.item_count):
		var item_text = resolution_button.get_item_text(i)
		if item_text.replace(" ", "") == expected_text:
			resolution_button.selected = i
			return
