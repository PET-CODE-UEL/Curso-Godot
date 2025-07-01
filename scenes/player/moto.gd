extends CharacterBody3D

@onready var interact_area = $InteractArea
@onready var mount_point = $MountPoint # <--- @onready para o seu MountPoint

var driver = null
var is_controlled = false
var speed = 10.0
var rotation_speed = 2.0
var gravity_strength = ProjectSettings.get_setting("physics/3d/default_gravity") 

@onready var player = get_node("/root/Main/Game/Player") # Caminho já corrigido

func _input(event):
	if is_controlled:
		if event.is_action_pressed("dismount_vehicle"):
			print("[MOTO DEBUG] Ação 'dismount_vehicle' detectada via _input na moto.")
			dismount()
			get_viewport().set_input_as_handled()
			
func enter():
	print("[MOTO DEBUG] Função 'enter' na moto chamada (provavelmente não usada).")

func _ready():
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	print("[MOTO DEBUG] Moto pronta. Sinais conectados.")

func _on_body_entered(body):
	if body.name == "Player":
		print("[MOTO DEBUG] Player entrou na área de interação da moto.")
		body.set_interactable(self)

func _on_body_exited(body):
	if body.name == "Player":
		print("[MOTO DEBUG] Player saiu da área de interação da moto.")
		body.set_interactable(null)

func mount(player_node):
	driver = player_node
	is_controlled = true
	driver.reparent(mount_point)
	driver.global_transform = mount_point.global_transform

	
	# 1. Desative completamente o processamento do player
	driver.mount_vehicle(mount_point)
	driver.set_process(false)
	driver.set_process_unhandled_input(false)
	driver.set_process_input(false)
	
	# 2. Esconda o player (se necessário, senão ele pode aparecer dentro do modelo da moto)
	driver.visible = false 
	
	# 3. Teleporte o player imediatamente para a posição e rotação do MountPoint
	# ISSO DEVE GRUDAR O PLAYER NO MOUNTPOINT
	driver.global_transform = mount_point.global_transform
	# Se o player precisa de um pequeno ajuste de altura em relação ao mount_point, descomente e ajuste:
	# driver.global_transform.origin += Vector3(0, 0.5, 0) # Exemplo: 0.5 unidades acima do mount_point

	# 4. Opcional: Alinhe a própria moto com o mount_point se ela não estiver na posição desejada inicial.
	#    Normalmente, a moto já estaria na sua posição correta antes do mount.
	# global_transform = mount_point.global_transform 
	
	print("[MOTO DEBUG] Player montou na moto!")
	print(" [MOTO DEBUG] Posição da moto após montar: %s" % str(global_transform.origin))
	print(" [MOTO DEBUG] Posição do player após montar: %s" % str(driver.global_transform.origin))


func dismount():
	if driver:
		# Posição de desmonte: um pouco à frente da moto e ligeiramente acima do chão
		var dismount_offset = global_transform.basis.z * 2.0 + Vector3(0, 1.0, 0)
		driver.global_transform.origin = global_transform.origin + dismount_offset
		
		driver.visible = true
		# Reative completamente o processamento do player
		driver.set_physics_process(true)
		driver.set_process(true)
		driver.set_process_unhandled_input(true)
		driver.set_process_input(true)
		
		print("[MOTO DEBUG] Player desmontou da moto!")
		print(" [MOTO DEBUG] Posição do player após desmontar: %s" % str(driver.global_transform.origin))
		
		driver = null
		is_controlled = false
		driver.dismount_vehicle()


func _physics_process(delta):
	if is_controlled:
		# Quando o player está desativado (set_process(false)), ele não se move.
		# Mas ele está "grudado" na posição global do mount_point.
		# Como o mount_point é filho da moto, ele se move *com a moto*.
		# Então, o player, que está na mesma posição do mount_point, também se move.
		
		var input_vector = Vector3.ZERO
		
		# Aplica a gravidade se não estiver no chão
		if not is_on_floor():
			velocity.y -= gravity_strength * delta
		
		if Input.is_action_pressed("ui_up"):
			input_vector.z -= 1
		if Input.is_action_pressed("ui_down"):
			input_vector.z += 1

		if Input.is_action_pressed("ui_left"):
			rotate_y(-delta * rotation_speed)
		if Input.is_action_pressed("ui_right"):
			rotate_y(delta * rotation_speed)

		if input_vector != Vector3.ZERO:
			input_vector = input_vector.normalized()
			var horizontal_direction = global_transform.basis * Vector3(0, 0, input_vector.z)
			velocity.x = horizontal_direction.x * speed
			velocity.z = horizontal_direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed * delta * 0.5)
			velocity.z = move_toward(velocity.z, 0, speed * delta * 0.5)

		move_and_slide()
		if driver:
			driver.global_transform = mount_point.global_transform
