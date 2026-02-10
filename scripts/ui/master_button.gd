class_name MasterButton extends Button

@onready var scale_slider = $Slider
@onready var scale_label = $Label

func _ready():
	scale_slider.value_changed.connect(on_slider_value_changed)
	update_label_text(scale_slider.value)

func on_slider_value_changed(value):
	if value == -45:
		AudioServer.set_bus_mute(0,true)
	else:
		AudioServer.set_bus_mute(0,false)
	AudioServer.set_bus_volume_db(0,value)
	update_label_text(value)
	
func update_label_text(value):
	var range_length = scale_slider.max_value - scale_slider.min_value
	var percent = (value - scale_slider.min_value) / range_length * 100
	scale_label.text = str(int(percent)) + "%"
