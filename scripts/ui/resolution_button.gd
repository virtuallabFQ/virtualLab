class_name ResolutionButton extends OptionButton

@export var window_button : WindowButton
@onready var scaling_button = get_node("../scaling_button")

var resolutions : Dictionary = {
	"1024x576" : Vector2i(1024, 576),
	"1280x720" : Vector2i(1280, 720),
	"1366x768" : Vector2i(1366, 768),
	"1600x900" : Vector2i(1600, 900),
	"1920x1080" : Vector2i(1920, 1080)
}

func _ready():
	var screen_size = DisplayServer.screen_get_size()
	var res_string = str(screen_size.x) + "x" + str(screen_size.y)
	resolutions[res_string] = screen_size
	add_resolutions()
	
	item_selected.connect(on_resolution_selected)
	get_window().set_size(screen_size)
	get_window().move_to_center()
	window_button.update_resolution(screen_size)
	
func add_resolutions():
	clear()
	var sorted_resolutions = resolutions.values()
	sorted_resolutions.sort()
	for r in sorted_resolutions:
		var label_text = str(r.x) + "x" + str(r.y)
		add_item(label_text)
		
func on_resolution_selected(index: int) -> void:
	var ID = get_item_text(index)
	get_window().set_size(resolutions[ID])
	scaling_button.reset_scaling_to_max()
	get_window().move_to_center()
