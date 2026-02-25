class_name AOButton extends OptionButton

func _ready():
	add_ao_items()
	check_current_ao()
	item_selected.connect(on_ao_selected)

func _get_environment() -> Environment:
	var world_env = get_tree().current_scene.find_child("WorldEnvironment", true, false)
	if world_env and world_env is WorldEnvironment:
		return world_env.environment
	return null

func add_ao_items() -> void:
	add_item("Desligado")
	add_item("Baixo")
	add_item("Médio")
	add_item("Alto")

func check_current_ao() -> void:
	var env = _get_environment()
	if env and not env.ssao_enabled:
		selected = 0
		return
		
	var current_ao = ProjectSettings.get_setting("rendering/environment/ssao/quality")
	match current_ao:
		RenderingServer.ENV_SSAO_QUALITY_LOW:
			selected = 1
		RenderingServer.ENV_SSAO_QUALITY_MEDIUM:
			selected = 2
		RenderingServer.ENV_SSAO_QUALITY_ULTRA:
			selected = 3

func on_ao_selected(index: int) -> void:
	var rs = RenderingServer
	var env = _get_environment()
	if index == 0:
		if env: env.ssao_enabled = false
		return
	
	if env: env.ssao_enabled = true
	match index:
		1:
			rs.environment_set_ssao_quality(rs.ENV_SSAO_QUALITY_LOW, true, 0.5, 1, 50.0, 60.0)
		2:
			rs.environment_set_ssao_quality(rs.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 100.0, 150.0)
		3:
			rs.environment_set_ssao_quality(rs.ENV_SSAO_QUALITY_ULTRA, false, 1.0, 3, 200.0, 300.0)
