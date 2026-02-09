class_name ReflectionsButton extends OptionButton

const atlas_size_path = "rendering/reflections/reflection_atlas/reflection_size"
const ggx_samples_path = "rendering/reflections/sky_reflections/ggx_samples"
const high_quality_filter_path = "rendering/reflections/sky_reflections/fast_filter_high_quality"
const ssr_roughness_path = "rendering/environment/screen_space_reflection/roughness_quality"
const ssr_steps_path = "rendering/environment/screen_space_reflection/steps"

func _ready():
	add_reflections_items()
	check_current_reflections()
	item_selected.connect(on_reflections_selected)

func add_reflections_items() -> void:
	add_item("Baixo")
	add_item("Médio")
	add_item("Alto")

func check_current_reflections() -> void:
	var current_reflections = ProjectSettings.get_setting(atlas_size_path)
	match current_reflections:
		256: selected = 0
		512: selected = 1
		1024: selected = 2

func on_reflections_selected(index: int) -> void:
	match index:
		0:
			ProjectSettings.set_setting(atlas_size_path, 256)
			ProjectSettings.set_setting(ggx_samples_path, 16)
			ProjectSettings.set_setting(high_quality_filter_path, false)
		1:
			ProjectSettings.set_setting(atlas_size_path, 512)
			ProjectSettings.set_setting(ggx_samples_path, 32)
			ProjectSettings.set_setting(high_quality_filter_path, true)
		2:
			ProjectSettings.set_setting(atlas_size_path, 1024)
			ProjectSettings.set_setting(ggx_samples_path, 64)
			ProjectSettings.set_setting(high_quality_filter_path, true)
