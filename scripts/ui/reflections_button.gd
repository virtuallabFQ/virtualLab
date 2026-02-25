class_name ReflectionsButton extends OptionButton

const atlas_size_path = "rendering/reflections/reflection_atlas/reflection_size"
const ggx_samples_path = "rendering/reflections/sky_reflections/ggx_samples"
const high_quality_filter_path = "rendering/reflections/sky_reflections/fast_filter_high_quality"

func _ready():
	add_reflections_items()
	check_current_reflections()
	item_selected.connect(on_reflections_selected)

func _get_environment() -> Environment:
	var world_env = get_tree().current_scene.find_child("WorldEnvironment", true, false)
	if world_env and world_env is WorldEnvironment:
		return world_env.environment
	return null

func add_reflections_items() -> void:
	add_item("Desligado")
	add_item("Baixo")
	add_item("Médio")
	add_item("Alto")

func check_current_reflections() -> void:
	var env = _get_environment()
	if env and not env.ssr_enabled:
		selected = 0
		return
		
	var current_reflections = ProjectSettings.get_setting(atlas_size_path)
	match current_reflections:
		256: selected = 1
		512: selected = 2
		1024: selected = 3

func on_reflections_selected(index: int) -> void:
	var env = _get_environment()
	if index == 0:
		if env: env.ssr_enabled = false
		return
	
	if env: env.ssr_enabled = true
	match index:
		1:
			ProjectSettings.set_setting(atlas_size_path, 256)
			ProjectSettings.set_setting(ggx_samples_path, 16)
			ProjectSettings.set_setting(high_quality_filter_path, false)
		2:
			ProjectSettings.set_setting(atlas_size_path, 512)
			ProjectSettings.set_setting(ggx_samples_path, 32)
			ProjectSettings.set_setting(high_quality_filter_path, true)
		3:
			ProjectSettings.set_setting(atlas_size_path, 1024)
			ProjectSettings.set_setting(ggx_samples_path, 64)
			ProjectSettings.set_setting(high_quality_filter_path, true)
