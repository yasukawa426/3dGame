extends CharacterBody3D

#Configuração base do jogador
#Velocidade base do jogador
const BASE_SPEED:float = 5.0
#Em quanto correr aumenta a velocidade
const SPRINT_MULTIPLIER: float = 2
#Velocidade de pulo
const JUMP_VELOCITY:float = 4.5
#Sensibilidade do mouse
const SENSITIVITY:float = 1
#Stamina máxima do jogador
const MAX_STAMINA:float = 50
#Intervalo que a stamina diminui ou aumenta
const STAMINA_CHANGE_INTERVAL = 0.5


#Velocidade atual do jogador, alterada em algumas situações.
var current_speed:float = BASE_SPEED
#Stamina atual do jogador
var current_stamina: float = MAX_STAMINA
#Diz se está correndo ou não
var is_sprinting: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Vetor com a direção do movimento baseado no input do jogador
var _input_dir:Vector2

# Assim que pronto, pegamos a cabeça do jogador
@onready var head = $CameraPivot
# Assim que pronto, pegamos a camera
@onready var camera = $CameraPivot/Camera3D
# Assim que pronto, pegamos o raio da visão do jogador
@onready var ray = $CameraPivot/InteractRay 

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
		
	
	#Caso estiver correndo, altera a velocidade e diminui a stamina
	#Caso não estiver, aumenta a stamina até a stamina maxima
	if is_sprinting:
		#Só corre caso tive stamina
		if current_stamina > STAMINA_CHANGE_INTERVAL:
			current_speed = BASE_SPEED * SPRINT_MULTIPLIER
			current_stamina -= STAMINA_CHANGE_INTERVAL
		
		#Caso a stamina acabar, fica negativa para ficar um tempo sem conseguir correr
		elif  current_stamina == STAMINA_CHANGE_INTERVAL or (current_stamina < STAMINA_CHANGE_INTERVAL and current_stamina > 0):
			current_stamina = -(MAX_STAMINA/2)
			current_speed = BASE_SPEED
		
		#Caso for <= 0, deixa na velocidade base e recupera stamina
		elif current_stamina <= 0:
			current_speed = BASE_SPEED
			current_stamina += STAMINA_CHANGE_INTERVAL
	else:
		#Caso não estiver na stamina base, carrega a stamina
		if current_stamina < MAX_STAMINA:
			current_stamina += STAMINA_CHANGE_INTERVAL
		
		#Nunca vai ser maior que a stamina maxima
		elif current_stamina > MAX_STAMINA:
			current_stamina = MAX_STAMINA
		
		current_speed = BASE_SPEED
	
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
	ray.rotate_x(-event.relative.y * SENSITIVITY/100)
	
		
	#limitamos quanto o jogador consegue movimentar a camera no eixo x
	#evitando girar completamente
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))	
	ray.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))	

#Fumção responsável por lidar com o teclado
func _handle_keyboard_input(event: InputEventKey):
	#Checa se o botão de correr está segurado e então altera a current_speed
	if Input.is_action_pressed("sprint"):
		is_sprinting = true
		
	elif Input.is_action_just_released("sprint"):
		is_sprinting = false

		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Pega a direção do movimento baseado nos inputs (esquerda, direita, frente e traz)
	_input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_back")
