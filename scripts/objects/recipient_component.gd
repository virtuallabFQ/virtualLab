class_name RecipientComponent extends Node

@export var liquid_mesh: MeshInstance3D ## Arrasta para aqui o cilindro de água que criaste dentro do copo!
@export var fill_speed := 0.2 ## Velocidade de enchimento (0.2 = demora 5 segundos a encher)
@export var max_height := 0.05 ## Altura máxima da malha de água no copo

var current_level := 0.0

func _ready() -> void:
	if liquid_mesh:
		liquid_mesh.visible = false
		liquid_mesh.scale.y = 0.001 # Começa invisível e vazio

# A função que vai ser "bombardeada" pelo esguicho
func receive_liquid(delta: float, material: Material) -> void:
	if not liquid_mesh or current_level >= 1.0: return
	
	# Quando cai a primeira gota, a água aparece com o shader exato do líquido que estamos a deitar!
	if not liquid_mesh.visible:
		liquid_mesh.visible = true
		if material: liquid_mesh.material_override = material
		
	# Sobe o nível
	current_level = clampf(current_level + (delta * fill_speed), 0.0, 1.0)
	
	# Faz a malha crescer. (O * 2.0 assume que o pivot do teu cilindro de água está no centro)
	var target_scale = max(0.001, current_level * max_height)
	liquid_mesh.scale.y = target_scale
	
	# Opcional: Se o cilindro crescer para baixo, descomenta a linha de baixo para o empurrar para cima
	# liquid_mesh.position.y = (target_scale / 2.0)
