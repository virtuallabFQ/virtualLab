class_name AOButton extends OptionButton

func _ready():
	add_ao_items()
	check_current_ao()
	item_selected.connect(on_ao_selected)

func add_ao_items() -> void:
	add_item("Baixo")
	add_item("Médio")
	add_item("Alto")

func check_current_ao() -> void:
	var current_ao = ProjectSettings.get_setting("rendering/environment/ssao/quality")
	match current_ao:
		RenderingServer.ENV_SSAO_QUALITY_LOW:
			selected = 0
		RenderingServer.ENV_SSAO_QUALITY_MEDIUM:
			selected = 1
		RenderingServer.ENV_SSAO_QUALITY_ULTRA:
			selected = 2

func on_ao_selected(index: int) -> void:
	var rs = RenderingServer
	match index:
		0:
			rs.environment_set_ssao_quality(rs.ENV_SSAO_QUALITY_LOW, true, 0.5, 1, 50.0, 60.0)
		1:
			rs.environment_set_ssao_quality(rs.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 100.0, 150.0)
		2:
			rs.environment_set_ssao_quality(rs.ENV_SSAO_QUALITY_ULTRA, false, 1.0, 3, 200.0, 300.0)
