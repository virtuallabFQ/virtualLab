class_name FOVButton extends Button

@onready var scale_slider = $Slider
@onready var scale_label = $Label

func _ready():
	scale_slider.value_changed.connect(on_slider_value_changed)
	scale_slider.value = Global.player_fov
	update_label_text(scale_slider.value)

func on_slider_value_changed(value):
	Global.player_fov = value
	get_tree().call_group("Player", "update_camera_settings")
	update_label_text(value)

func update_label_text(value):
	scale_label.text = str(int(value)) + "º"
