class_name ShadowsButton extends OptionButton

func _ready():
	add_shadows_items()
	check_current_shadows()
	item_selected.connect(on_shadows_selected)

func add_shadows_items() -> void:
	add_item("Baixo")
	add_item("Médio")
	add_item("Alto")

func check_current_shadows() -> void:
	var current_shadows = get_viewport().positional_shadow_atlas_size
	match current_shadows:
		2048:
			selected = 0
		4096:
			selected = 1
		8192:
			selected = 2

func on_shadows_selected(index: int) -> void:
	var rs = RenderingServer 
	var viewport = get_viewport()
	match index:
		0:
			rs.directional_shadow_atlas_set_size(2048, true)
			viewport.positional_shadow_atlas_size = 2048
			rs.directional_soft_shadow_filter_set_quality(rs.SHADOW_QUALITY_SOFT_ULTRA)
			rs.positional_soft_shadow_filter_set_quality(rs.SHADOW_QUALITY_SOFT_ULTRA)
		1:
			rs.directional_shadow_atlas_set_size(4096, true)
			viewport.positional_shadow_atlas_size = 4096
			rs.directional_soft_shadow_filter_set_quality(rs.SHADOW_QUALITY_SOFT_ULTRA)
			rs.positional_soft_shadow_filter_set_quality(rs.SHADOW_QUALITY_SOFT_ULTRA)
		2:
			rs.directional_shadow_atlas_set_size(8192, true)
			viewport.positional_shadow_atlas_size = 8192
			rs.directional_soft_shadow_filter_set_quality(rs.SHADOW_QUALITY_SOFT_ULTRA)
			rs.positional_soft_shadow_filter_set_quality(rs.SHADOW_QUALITY_SOFT_ULTRA)
