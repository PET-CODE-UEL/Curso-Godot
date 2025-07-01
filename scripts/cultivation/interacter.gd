extends Node3D

var distance = 100.0

signal update_prompt_text
signal harvested_crop

@onready var hand_anim_tree: AnimationTree = get_node("../CameraPivot/FirstPerson/Hand/AnimationTree")
@export var corn_scene : PackedScene
@export var tomato_scene : PackedScene
@export var plantation_scene : PackedScene
@export var chicken_scene : PackedScene

var controlled_vehicle = null

func set_interactable(vehicle_node):
	# Adaptação: Usando %s para o nome do nó
	print("[PLAYER DEBUG] set_interactable chamado. Recebeu: %s" % (vehicle_node.name if vehicle_node else 'null'))
	pass

func _process(_delta):
	if controlled_vehicle:
		# Remova a linha abaixo, a moto agora lida com o input de desmontar
		# print("[PLAYER DEBUG] Ação 'dismount_vehicle' pressionada.")
		# Remova a linha abaixo, a moto agora lida com o input de desmontar
		# dismount_vehicle()
		emit_signal("update_prompt_text", "")
		return # <-- Muito importante: Sai do _process do player se estiver na moto!

	else:
		if UIManager.is_inventory_open or UIManager.is_shop_open or UIManager.is_pause_open:
			emit_signal("update_prompt_text", "")
			return
			
		var hotbar = get_node_or_null("/root/Main/UI/HUD/Margin/Margin/Hotbar")
		var item_atual
		if hotbar:
			var selected_item = InventoryManager.get_hotbar_item(hotbar.selected_index)
			if selected_item:
				item_atual = selected_item.name
				
		if Input.is_action_just_pressed("interacao") and item_atual == "Foice":
			interact()
			set_item_interagir(true)
		if Input.is_action_just_pressed("plant") and item_atual != null:
			plant(item_atual)
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
		
		var vehicle_ray = raycast(16)
		if vehicle_ray:
			# Adaptação: Usando %s para o nome e %d para a camada
			#print("[PLAYER DEBUG] Raycast de veículo atingiu: %s. Camada: %d" % [vehicle_ray.collider.name, vehicle_ray.collider.get_collision_layer()])
			if vehicle_ray.collider and vehicle_ray.collider.has_method("mount"):
				emit_signal("update_prompt_text", "Pressione [E] para entrar na moto")
				if Input.is_action_just_pressed("enter_vehicle"):
					print("[PLAYER DEBUG] Ação 'enter_vehicle' pressionada. Tentando entrar na moto.")
					enter_vehicle(vehicle_ray.collider)
					emit_signal("update_prompt_text", "")
					return
			#else:
				#print("[PLAYER DEBUG] Raycast atingiu %s, mas não é um veículo montável ou não tem o método 'mount'." % vehicle_ray.collider.name)
		#else:
			#print("[PLAYER DEBUG] Raycast de veículo não atingiu nada.")

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
			if not vehicle_ray: # Evita apagar o prompt da moto se ela foi detectada
				emit_signal("update_prompt_text", "")
		
		await get_tree().create_timer(0.1).timeout
		set_item_interagir(false)

func enter_vehicle(vehicle_node):
	if vehicle_node and vehicle_node.has_method("mount"):
		# Adaptação: Usando %s para o nome do nó
		print("[PLAYER DEBUG] Chamando mount() em %s." % vehicle_node.name)
		vehicle_node.mount(self)
		controlled_vehicle = vehicle_node
		# Adaptação: Usando %s para o nome do nó
		print("[PLAYER DEBUG] controlled_vehicle agora é: %s" % controlled_vehicle.name)
	else:
		# Adaptação: Usando %s para o nome do nó
		print("[PLAYER DEBUG] Tentativa de enter_vehicle falhou: %s não é válido ou não tem mount()." % (vehicle_node.name if vehicle_node else 'null'))

func dismount_vehicle():
	if controlled_vehicle:
		# Adaptação: Usando %s para o nome do nó
		print("[PLAYER DEBUG] Chamando dismount() em %s." % controlled_vehicle.name)
		controlled_vehicle.dismount()
		controlled_vehicle = null
		print("[PLAYER DEBUG] controlled_vehicle resetado para null.")
	else:
		print("[PLAYER DEBUG] Tentativa de dismount_vehicle falhou: controlled_vehicle é null.")

# ==============================================================================
# SEGUEM AS FUNCOES BASICAS DO JOGO
# NOTA SE QUE ELAS SE ASSEMELHAM MUITO
# 1 - JOGAR O RAYCAST NA CAMADA DO OBJETO QUE SERA USADO
# 2 - CHECAR SE O RAIO ENCONTROU O OBJETO EM QUESTAO
# 3 - FAZER AS MUDANCAS NECESSARIAS

# FUNCAO DE COLHER
func interact():
	var result = raycast(2) # Camada de colisao 2 -> 010 b = 2 d
	print("interagiu") # Não tem variáveis para formatar aqui
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
func plant(item_name: String) -> void:
	var crop_type: CropTypes.CROP_TYPE

	match item_name:
		"Tomate":
			crop_type = CropTypes.CROP_TYPE.TOMATO
		"Milho":
			crop_type = CropTypes.CROP_TYPE.CORN
		_:
			return  # Nome inválido, não planta

	var result = raycast(4)
	if result and result.collider.get_collision_layer() == 4:
		var soil = result.collider
		if not soil.occupied:
			var crop_instance

			match crop_type:
				CropTypes.CROP_TYPE.CORN:
					crop_instance = corn_scene.instantiate()
				CropTypes.CROP_TYPE.TOMATO:
					crop_instance = tomato_scene.instantiate()
				_:
					return

			crop_instance.plantation = soil
			get_tree().get_root().add_child(crop_instance)
			crop_instance.global_transform.origin = soil.global_transform.origin
			crop_instance.rotate_y(randf_range(0.0, TAU))
			crop_instance.global_scale(Vector3.ONE * randf_range(0.9, 1.1))

			soil.occupied = true
			soil.crop = crop_instance
			if soil.fertilized:
				crop_instance.growth_time *= 0.9

			InventoryManager.remove_item_from_inventory(item_name, 1)  # ✅ Remove 1 unidade
# FUNCAO DE CRIAR O SOLO DE PLANTIO
func prepare_ground():
	var result = raycast(1)
	if result:
		if result.collider.get_collision_layer() == 1:
			# Adaptação: Usando %d para a camada
			print("Raio colidiu com: %d" % result.collider.get_collision_layer())
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
					print("Regado") # Não tem variáveis para formatar aqui
					crop.growth_value += 0.1 # Acelera 10% o crescimento
					crop.watered = true

# FUNCAO DE FERTILIZAR O SOLO
func fertilizing_soil():
	var result = raycast(4)
	if result:
		if result.collider.get_collision_layer() == 4:
			var soil = result.collider
			if !soil.fertilized: # Se o solo tiver uma planta e nao estiver fertilizado
				print("Fertilizado") # Não tem variáveis para formatar aqui
				soil.fertilized = true

# FUNCAO BASICA DE RAYCAST (sem prints aqui)
func raycast(layer: int):
	var space_state = get_world_3d().get_direct_space_state()
	var cam = get_node("../CameraPivot/FirstPerson") # Caminho para a câmera
	var mouse_pos = get_viewport().get_mouse_position()

	# Calcula a origem e a direção do raio com base na posição do mouse
	var origin = cam.project_ray_origin(mouse_pos)
	var end = origin + cam.project_ray_normal(mouse_pos) * distance

	# Configurando os parâmetros do raycast
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = end
	query.collision_mask = layer # Camada de colisão
	query.collide_with_areas = true # Permitir colisão com áreas

	# Executando o raycast
	var result = space_state.intersect_ray(query)
	return result

# FUNCAO PRA SPAWNAR GALINHAS (sem prints aqui)
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
