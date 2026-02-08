extends Button

@onready var scale_slider = $slider
@onready var scale_label = $label

func _ready():
	_on_slider_value_changed(100.0)

func _on_slider_value_changed(value: float) -> void:
	var resolution_scale = value/100.00
	var width = int(round(get_window().get_size().x * resolution_scale))
	var height = int(round(get_window().get_size().y * resolution_scale))
	var resolution_text = str(width) + "x" + str(height)
	
	scale_label.set_text(resolution_text + " (" + str(int(value)) + "%)")
	get_viewport().set_scaling_3d_scale(resolution_scale)
