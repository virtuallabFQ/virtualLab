class_name MasterButton extends Button

@onready var scale_slider = $Slider
@onready var scale_label = $Label

func _ready():
	scale_slider.value_changed.connect(on_slider_value_changed)

func on_slider_value_changed(value):
	if value == -45:
		AudioServer.set_bus_mute(0,true)
	else:
		AudioServer.set_bus_mute(0,false)
	AudioServer.set_bus_volume_db(0,value)
