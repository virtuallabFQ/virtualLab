class_name ScalingModeButton extends OptionButton

@export var scaling_button : ScalingButton
@export var fsr_options_button : FSROptionsButton
@export var aa_button : AAButton

func _ready():
	add_scaling_mode_items()
	call_deferred("check_current_scaling_mode")
	item_selected.connect(on_scaling_mode_selected)

func add_scaling_mode_items() -> void:
	add_item("Nativo")
	add_item("AMD FSR 2")

func check_current_scaling_mode():
	var viewport = get_viewport()
	var scaling_mode = viewport.scaling_3d_mode
	if scaling_mode == Viewport.SCALING_3D_MODE_BILINEAR:
		scaling_button.scale_slider.editable = true
		fsr_options_button.disabled = true
		fsr_options_button.selected = 1
		aa_button.disabled = false
	elif scaling_mode == Viewport.SCALING_3D_MODE_FSR2:
		scaling_button.scale_slider.editable = false
		fsr_options_button.disabled = false
		fsr_options_button.selected = 1
		fsr_options_button.on_fsr_options_selected(1)
		aa_button.disabled = true
		
	var current_scale = viewport.scaling_3d_scale
	scaling_button.scale_slider.value = current_scale * 100
	scaling_button.on_slider_value_changed(scaling_button.scale_slider.value)

func on_scaling_mode_selected(index: int) -> void:
	var viewport = get_viewport()
	match index:
		0:
			viewport.set_scaling_3d_mode(Viewport.SCALING_3D_MODE_BILINEAR)
			scaling_button.scale_slider.set_editable(true)
			scaling_button.reset_scaling_to_default()
			fsr_options_button.disabled = true
			aa_button.disabled = false
			aa_button.selected = 2 
		1:
			viewport.set_scaling_3d_mode(Viewport.SCALING_3D_MODE_FSR2)
			scaling_button.scale_slider.set_editable(false)
			fsr_options_button.disabled = false
			fsr_options_button.selected = 1
			fsr_options_button.on_fsr_options_selected(1)
			aa_button.disabled = true
			aa_button.selected = 0
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
