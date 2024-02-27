extends CharacterBody3D

#Configuração base do jogador
#Velocidade base do jogador
const BASE_SPEED:float = 5.0
#Em quanto correr aumenta a velocidade
const SPRINT_MULTIPLIER: float = 1.5
#Velocidade de pulo
const JUMP_VELOCITY:float = 4.5
#Sensibilidade do mouse
const SENSITIVITY:float = 1


#Velocidade atual do jogador, alterada em algumas situações.
var current_speed:float = BASE_SPEED

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Vetor com a direção do movimento baseado no input do jogador
var _input_dir:Vector2

# Assim que pronto, pegamos a cabeça do jogador
@onready var head = $CameraPivot

# Assim que pronto, pegamos a camera
@onready var camera = $CameraPivot/Camera3D

#Executado assim que o jogador está pronto
func _ready():
	#Capturamos o mouse para futuramente usalo como movimento da camera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Chamado a cada frame de fisica
func _physics_process(delta:float):
	#Chama a função de movimento
	_handle_movement(delta)


#Essa função deve ser usada para consumir eventos de UI
func _input(event):
	pass


#Essa função deve ser usada pra consumir eventos de gameplay
#Pegamos os input não usados
func _unhandled_input(event:InputEvent):
	#Caso o evento for do tipo movimento do mouse
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
		
	#Caso for algum evento de tecla
	elif event is InputEventKey:
		_handle_keyboard_input(event)
		
	else:
		pass

#Função responsável pela movimentação do player
func _handle_movement(delta:float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#A direção é baseada pra onde a camera esta olhando
	var direction = (head.transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
	#Caso não tiver nenhuma direção, desacelera até 0.
	else:
		#Esse código deveria desacelerar o corpo como uma forma de fricção, mas como estamos usando a velocidade
		#O corpo é desacelerado instantaneamente, não funcionando como esperado.
		#Erro direto do código do godot
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	#Move com os vetores criados
	move_and_slide()

#Função responsável por lidar com o movimento do mouse
func _handle_mouse_motion(event: InputEventMouseMotion):
	#separamos a rotação para evitar rotar o mundo
	head.rotate_y(-event.relative.x * SENSITIVITY/100)
	camera.rotate_x(-event.relative.y * SENSITIVITY/100)
		
	#limitamos quanto o jogador consegue movimentar a camera no eixo x
	#evitando girar completamente
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))	

#Fumção responsável por lidar com o teclado
func _handle_keyboard_input(event: InputEventKey):
	#Checa se o botão de correr está segurado e então altera a current_speed
	if Input.is_action_pressed("sprint"):
		current_speed = BASE_SPEED * SPRINT_MULTIPLIER
	else:
		current_speed = BASE_SPEED
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Pega a direção do movimento baseado nos inputs (esquerda, direita, frente e traz)
	_input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_back")
