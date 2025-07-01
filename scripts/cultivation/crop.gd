extends StaticBody3D

@export var crop_type: CropTypes.CROP_TYPE # TIPO DE PLANTA A SER USADA
@export var harvest_amount = 1 # QUANTIDADE QUE DROPA

# FASES DO SPRITE DA PLANTA
@onready var large = $Large
@onready var medium = $Medium
@onready var small = $Small
# VALUE EH O MOMENTO ATUAL DA PLANTA E TIME E O TEMPO TOTAL QUE LEVA PARA CRESCER
var growth_value = 0.0
var growth_time = 30

var watered = false # CHECA SE JA FOI REGADA HOJE
var harvestable = false # CHECA SE JA PODE COLHER
var plantation: Node = null # REFERENCIA O SOLO EM QUE FOI PLANTADA

func get_harvest_amount():
	return harvest_amount
	
func get_crop_type():
	return crop_type

func interact():
	if not harvestable:
		return

	var inventory_manager = get_node("/root/InventoryManager")
	var item_path := get_crop_resource_path(crop_type)

	if item_path != "":
		var crop_resource = load(item_path)
		if crop_resource:
			for i in harvest_amount:
				var crop_item = crop_resource.duplicate()
				inventory_manager.add_item_to_inventory(crop_item)
		else:
			print("Erro ao carregar recurso: ", item_path)
	else:
		print("Tipo de planta inválido ou não definido")

	queue_free()


func get_crop_resource_path(crop_type: CropTypes.CROP_TYPE) -> String:
	match crop_type:
		CropTypes.CROP_TYPE.CORN:
			return "res://resources/items/corn.tres"
		CropTypes.CROP_TYPE.TOMATO:
			return "res://resources/items/tomato.tres"
		_:
			return ""
		
func update_prompt_text(): # INTERFACE DO JOGO
	if harvestable:
		return "Botao Esquerdo do Mouse para Colher"
	else :
		if !watered:
			return "Aperte R para Regar"
		return ""

# PROCESSA CRESCIMENTO DA PLANTA
func _process(delta):
	if growth_value < 1.0: # ESSE VALOR EH PORCENTAGEM QUE A PLANTA JA CRESCEU
		growth_value += delta / growth_time
	
	# Ajustar visibilidade com base no crescimento
	small.visible = growth_value < 0.5
	medium.visible = growth_value >= 0.5 and growth_value < 1.0
	large.visible = growth_value >= 1.0

	# Controlar lógica de colisionabilidade ou processamento (exemplo para StaticBody3D)
	small.set_physics_process(growth_value < 0.5)
	medium.set_physics_process(growth_value >= 0.5 and growth_value < 1.0)
	large.set_physics_process(growth_value >= 1.0)
	
	# Determinar se está colhível
	harvestable = growth_value >= 1.0
