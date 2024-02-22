extends CharacterBody3D

#Velocidade base do jogador
const BASE_SPEED:float = 5.0

#Sensibilidade do mouse
const SENSITIVITY:float = 1

#Velocidade atual do jogador, alterada em algumas situações.
var current_speed:float = BASE_SPEED

#Velocidade de pulo
const JUMP_VELOCITY:float = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Assim que pronto, pegamos a cabeça do jogador
@onready var head = $CameraPivot

# Assim que pronto, pegamos a camera
@onready var camera = $CameraPivot/Camera3D

#Executado assim que o jogador está pronto
func _ready():
	#Capturamos o mouse para futuramente usalo como movimento da camera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Pegamos os input não usados
func _unhandled_input(event:InputEvent):
	#Caso o evento for do tipo movimento do mouse
	if event is InputEventMouseMotion:
		#separamos a rotação para evitar rotar o mundo
		head.rotate_y(-event.relative.x * SENSITIVITY/100)
		camera.rotate_x(-event.relative.y * SENSITIVITY/100)
		
		#limitamos quanto o jogador consegue movimentar a camera no eixo x
		#evitando girar completamente
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta:float):
	#Chama a função de movimento
	_handle_movement(delta)

#Função responsável pela movimentação do player
func _handle_movement(delta:float):
	
	#Checa se o botão de correr está segurado e então altera a current_speed
	if Input.is_action_pressed("sprint"):
		current_speed = BASE_SPEED * 1.5
	else:
		current_speed = BASE_SPEED
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_back")
	
	#A direção é baseada pra onde a camera esta olhando
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	#Caso não estiver com nenhum botão apertado, desacelera até 0.
	else:
		#Esse código deveria desacelerar o corpo como uma forma de fricção, mas como estamos usando a velocidade
		#O corpo é desacelerado instantaneamente, não funcionando como esperado.
		#Erro direto do código do godot
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	#Move com os vetores criados
	move_and_slide()
