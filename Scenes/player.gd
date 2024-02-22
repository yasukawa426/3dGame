extends CharacterBody3D

#Velocidade base do jogador
const BASE_SPEED:float = 5.0

#Velocidade atual do jogador, alterada em algumas situações.
var current_speed:float = BASE_SPEED

#Velocidade de pulo
const JUMP_VELOCITY:float = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	


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
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		$shrek_model/AnimationPlayer.play("walk")
		
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	#Caso não estiver com nenhum botão apertado, desacelera até 0.
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
		if Input.is_action_just_pressed("dance"):
			$shrek_model/AnimationPlayer.play("dance")
			
		elif not $shrek_model/AnimationPlayer.is_playing():
			$shrek_model/AnimationPlayer.play("idle")
	
	#Move com os vetores criados
	move_and_slide()
