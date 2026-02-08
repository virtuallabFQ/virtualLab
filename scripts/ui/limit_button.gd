class_name LimitButton extends Button

@onready var limit_slider = $slider
@onready var limit_label = $label

func _ready():
	check_current_limit()
	limit_slider.value_changed.connect(_on_slider_value_changed)

func check_current_limit():
	var current_limit = Engine.max_fps
	if current_limit == 0:
		limit_slider.value = limit_slider.max_value
	else:
		limit_slider.value = current_limit
	_on_slider_value_changed(limit_slider.value)

func _on_slider_value_changed(value: float) -> void:
	var target_fps = int(value)
	if target_fps >= limit_slider.max_value:
		Engine.max_fps = 0
		limit_label.set_text("Ilimitado")
	else:
		Engine.max_fps = target_fps
		limit_label.set_text(str(target_fps) + " FPS")
