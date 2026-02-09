class_name FSROptionsButton extends OptionButton

@export var scaling_button : ScalingButton

func _ready():
	add_fsr_options_items()
	item_selected.connect(on_fsr_options_selected)

func add_fsr_options_items() -> void:
	add_item("Performance")
	add_item("Equilibrado")
	add_item("Qualidade")
	add_item("Alta Qualidade")

func on_fsr_options_selected(index: int) -> void:
	match index:
		0:
			scaling_button.on_slider_value_changed(50.0)
		1:
			scaling_button.on_slider_value_changed(59.0)
		2:
			scaling_button.on_slider_value_changed(67.0)
		3:
			scaling_button.on_slider_value_changed(77.0)
