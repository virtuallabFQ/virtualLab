class_name AAButton extends OptionButton

func _ready():
	add_aa_items()
	check_current_aa()
	item_selected.connect(_on_aa_selected)

func add_aa_items() -> void:
	add_item("Desativado")
	add_item("2x")
	add_item("4x")
	add_item("8x")

func check_current_aa() -> void:
	var current_msaa = get_viewport().msaa_3d
	match current_msaa:
		Viewport.MSAA_DISABLED:
			selected = 0
		Viewport.MSAA_2X:
			selected = 1
		Viewport.MSAA_4X:
			selected = 2
		Viewport.MSAA_8X:
			selected = 3

func _on_aa_selected(index: int) -> void:
	match index:
		0:
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		1:
			get_viewport().msaa_3d = Viewport.MSAA_2X
		2:
			get_viewport().msaa_3d = Viewport.MSAA_4X
		3:
			get_viewport().msaa_3d = Viewport.MSAA_8X
