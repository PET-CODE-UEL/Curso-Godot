extends Node3D

var distance = 100.0

signal update_prompt_text
signal harvested_crop

@onready var hand_anim_tree: AnimationTree = get_node("../Hand/AnimationTree")
@export var corn_scene : PackedScene
@export var tomato_scene : PackedScene
@export var plantation_scene : PackedScene
@export var chicken_scene : PackedScene

# PROCESS QUE CHECA A POSSIBILIDADE DE ACOES
func _process(_delta):
	var hotbar = get_node_or_null("/root/Main/UI/HUD/Margin/Margin/Hotbar")  # 🔥 Obtendo a hotbar
	var item_atual
	if hotbar:
		var selected_item = InventoryManager.get_hotbar_item(hotbar.selected_index)  # 🔥 Pegando o item no slot selecionado
		if selected_item:
			item_atual = selected_item.name
			
	if Input.is_action_just_pressed("interacao") and item_atual == "Foice":
		interact()
		set_item_interagir(true)
	if Input.is_action_just_pressed("plant"):
		plant(CropTypes.CROP_TYPE.TOMATO)
		set_item_interagir(true)
	if Input.is_action_just_pressed("prepare_ground") and item_atual == "Enxada":
		prepare_ground()
		set_item_interagir(true)
	if Input.is_action_just_pressed("watering_crop") and item_atual == "Regador":
		watering_crop()
		set_item_interagir(true)
	if Input.is_action_just_pressed("fertilizing"):
		fertilizing_soil()
		set_item_interagir(true)
	if Input.is_action_just_pressed("spawn_chicken"):
		spawn_chicken()
		set_item_interagir(true)
	if Input.is_action_just_pressed("collect_egg"):
		collect_egg()
		set_item_interagir(true)
	
	var crop_ray = raycast(2)
	var soil_ray = raycast(4)
	var ground_ray = raycast(1)
	var chicken_ray = raycast(8)
	if chicken_ray:
		emit_signal("update_prompt_text", chicken_ray.collider.update_prompt_text())
	elif crop_ray :
		emit_signal("update_prompt_text", crop_ray.collider.update_prompt_text())
	elif soil_ray:
		emit_signal("update_prompt_text", soil_ray.collider.update_prompt_text())
	elif ground_ray and item_atual == "Enxada":
		emit_signal("update_prompt_text", ground_ray.collider.update_prompt_text())
	else:
		emit_signal("update_prompt_text", "")
	
	await get_tree().create_timer(0.1).timeout
	set_item_interagir(false)
# ==============================================================================
# SEGUEM AS FUNCOES BASICAS DO JOGO
# NOTA SE QUE ELAS SE ASSEMELHAM MUITO
# 1 - JOGAR O RAYCAST NA CAMADA DO OBJETO QUE SERA USADO
# 2 - CHECAR SE O RAIO ENCONTROU O OBJETO EM QUESTAO
# 3 - FAZER AS MUDANCAS NECESSARIAS

# FUNCAO DE COLHER
func interact():
	var result = raycast(2) # Camada de colisao 2 -> 010 b = 2 d
	print("interagiu")
	if result:
		if result.collider.get_collision_layer() == 2:
			var crop = result.collider
			if crop.harvestable:
				emit_signal("harvested_crop", crop.get_crop_type(),crop.get_harvest_amount())
				crop.interact()
				
				crop.plantation.occupied = false # Desocupa o solo
				crop.plantation.fertilized = false # Remove fertilizande do solo
				crop.plantation.crop = null # Remove referencia da crop em plantation

# FUNCAO DE PLANTAR
func plant(type : CropTypes.CROP_TYPE):
	var result = raycast(4) # Camada de colisao 3 -> 100 b = 4 d
	if result:
		if result.collider.get_collision_layer() == 4  : # Checa se eh um terreno pra plantar
			var soil = result.collider
			if !soil.occupied : # Checa se o terreno ja esta ocupado
				var crop_instance
				if type == CropTypes.CROP_TYPE.CORN:
					crop_instance = corn_scene.instantiate()
					print("CORN")
					
				elif type == CropTypes.CROP_TYPE.TOMATO:
					crop_instance = tomato_scene.instantiate()
					print("TOMATO")
					
				crop_instance.plantation = soil
				get_tree().get_root().add_child(crop_instance)
				 # Calcula o centro do quadrado
				var center_position = soil.global_transform.origin
				crop_instance.global_transform.origin = center_position
				
				crop_instance.rotate_y(randf_range(0.0, TAU))
				crop_instance.global_scale(Vector3.ONE * randf_range(0.9,1.1))
				soil.occupied = true # Ocupa terreno
				soil.crop = crop_instance # Referencia a planta ao terreno
				if soil.fertilized:
					crop_instance.growth_time *= 0.9 # Diminui o tempo de crescimento em 10% 

# FUNCAO DE CRIAR O SOLO DE PLANTIO
func prepare_ground():
	var result = raycast(1)
	if result:
		if result.collider.get_collision_layer() == 1:
			print("Raio colidiu com: ", result.collider.get_collision_layer())
			var plantation_instance = plantation_scene.instantiate()
			get_tree().get_root().add_child(plantation_instance)
			plantation_instance.global_transform.origin = result.position

# FUNCAO DE REGAR A PLANTA 
func watering_crop():
	var result = raycast(2)
	if result:
		if result.collider.get_collision_layer() == 2:
				var crop = result.collider
				if !crop.watered:
					print("Regado")
					crop.growth_value += 0.1 # Acelera 10% o crescimento
					crop.watered = true

# FUNCAO DE FERTILIZAR O SOLO
func fertilizing_soil():
	var result = raycast(4)
	if result:
		if result.collider.get_collision_layer() == 4:
			var soil = result.collider
			if !soil.fertilized: # Se o solo tiver uma planta e nao estiver fertilizado
				print("Fertilizado")
				soil.fertilized = true

# FUNCAO BASICA DE RAYCAST
func raycast(layer: int):
	var space_state = get_world_3d().get_direct_space_state()
	var cam = get_node("../CameraPivot/FirstPerson")  # Caminho para a câmera
	var mouse_pos = get_viewport().get_mouse_position()

	# Calcula a origem e a direção do raio com base na posição do mouse
	var origin = cam.project_ray_origin(mouse_pos)
	var end = origin + cam.project_ray_normal(mouse_pos) * distance

	# Configurando os parâmetros do raycast
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = end
	query.collision_mask = layer  # Camada de colisão
	query.collide_with_areas = true  # Permitir colisão com áreas

	# Executando o raycast
	var result = space_state.intersect_ray(query)
	return result

# FUNCAO PRA SPAWNAR GALINHAS
func spawn_chicken():
	var result = raycast(1)
	if result:
		var chicken_instance = chicken_scene.instantiate()
		chicken_instance.global_transform.origin = result.position + Vector3.UP * 0.5
		get_tree().get_root().add_child(chicken_instance)

func collect_egg():
	var result = raycast(8)
	if result:
		if result.collider:
			result.collider.interact()
			
func set_item_interagir(value: bool):
	hand_anim_tree["parameters/conditions/interagindo"] = value
