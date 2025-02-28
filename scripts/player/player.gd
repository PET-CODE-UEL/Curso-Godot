extends CharacterBody3D

# Movimentação
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Movimentação da Câmera
@export var mouse_sensitivity := Vector2(0.01, 0.01)
var rotation_horizontal := 0.0
var rotation_vertical := 0.0

# Câmeras
@onready var camera_pivot : Node3D = $CameraPivot

@onready var skeleton: Skeleton3D = $"CollisionShape/PlayerModel/Armação/Skeleton3D"

func _ready() -> void:
	update_camera_mode()


func _process(_delta: float) -> void:
	rotation.y = rotation_horizontal
	camera_pivot.rotation.x = rotation_vertical


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_horizontal -= event.relative.x * mouse_sensitivity.x 
		rotation_vertical -= event.relative.y * mouse_sensitivity.y
		rotation_vertical = clamp(rotation_vertical, deg_to_rad(-90), deg_to_rad(90))

func toggle_visibility(is_first_person: bool) -> void:
	for child in skeleton.get_children():
		if child is MeshInstance3D:
			if is_first_person:
				child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
			else:
				child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

func update_camera_mode():
	toggle_visibility(true)