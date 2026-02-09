class_name LimitButton extends Button

@onready var limit_slider = $Slider
@onready var limit_label = $Label

func _ready():
	check_current_limit()
	limit_slider.value_changed.connect(on_slider_value_changed)

func check_current_limit():
	var current_limit = Engine.max_fps
	if current_limit == 0:
		limit_slider.value = limit_slider.max_value
	else:
		limit_slider.value = current_limit
	on_slider_value_changed(limit_slider.value)

func on_slider_value_changed(value: float) -> void:
	var target_fps = int(value)
	if target_fps >= limit_slider.max_value:
		Engine.max_fps = 0
		limit_label.set_text("Ilimitado")
	else:
		Engine.max_fps = target_fps
		limit_label.set_text(str(target_fps) + " FPS")
