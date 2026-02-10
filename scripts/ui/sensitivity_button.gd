class_name SensitivityButton extends Button

@onready var scale_slider = $Slider
@onready var scale_label = $Label

func _ready():
	scale_slider.value_changed.connect(on_slider_value_changed)
	scale_slider.value = Global.mouse_sensitivity * 100.0
	update_label_text(scale_slider.value)

func on_slider_value_changed(value):
	Global.mouse_sensitivity = value / 100.0
	update_label_text(value)

func update_label_text(value):
	scale_label.text = str(snapped(value, 0.01))
