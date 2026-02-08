class_name ScalingButton extends Button

@onready var scale_slider = $slider
@onready var scale_label = $label
@onready var fsr_options_button = get_node("../fsr_options_button")
@onready var aa_button = get_node("../aa_button")

func reset_scaling_to_max() -> void:
	scale_slider.value = 100.0
	_on_slider_value_changed(100.0)
	
func _ready():
	check_current_scaling()

func check_current_scaling():
	var viewport = get_viewport()
	var scaling_mode = viewport.scaling_3d_mode

	if scaling_mode == Viewport.SCALING_3D_MODE_BILINEAR:
		scale_slider.editable = true
		fsr_options_button.disabled = true
		aa_button.disabled = false
	elif scaling_mode == Viewport.SCALING_3D_MODE_FSR2:
		scale_slider.editable = false
		fsr_options_button.disabled = false
		aa_button.disabled = true
		
	var current_scale = viewport.scaling_3d_scale
	scale_slider.value = current_scale * 100
	_on_slider_value_changed(scale_slider.value)

func _on_slider_value_changed(value: float) -> void:
	var resolution_scale = value/100.00
	var width = int(round(get_window().get_size().x * resolution_scale))
	var height = int(round(get_window().get_size().y * resolution_scale))
	var resolution_text = str(width) + "x" + str(height)
	
	scale_label.set_text(resolution_text + " (" + str(int(value)) + "%)")
	get_viewport().set_scaling_3d_scale(resolution_scale)

func _on_scaling_mode_button_item_selected(index: int) -> void:
	var viewport = get_viewport()
	match index:
		0:
			viewport.set_scaling_3d_mode(Viewport.SCALING_3D_MODE_BILINEAR)
			scale_slider.set_editable(true)
			reset_scaling_to_max()
			fsr_options_button.disabled = true
			aa_button.disabled = false
			aa_button.selected = 2 
			viewport.msaa_3d = Viewport.MSAA_4X
		1:
			viewport.set_scaling_3d_mode(Viewport.SCALING_3D_MODE_FSR2)
			scale_slider.set_editable(false)
			fsr_options_button.disabled = false
			fsr_options_button.selected = 1
			_on_fsr_options_button_item_selected(1)
			aa_button.disabled = true
			viewport.msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			get_viewport().use_taa = false

func _on_fsr_options_button_item_selected(index: int) -> void:
	match index:
		0:
			_on_slider_value_changed(50.0)
		1:
			_on_slider_value_changed(59.0)
		2:
			_on_slider_value_changed(67.0)
		3:
			_on_slider_value_changed(77.0)
