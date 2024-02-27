extends Node

#Esse script contem alguns códigos gerais do mundo, q devem estar presentes em todas as cenas.
#Por enquanto temos só os shortcuts do modo debug.

# Called when the node enters the scene tree for the first time.
func _ready():	
	print_debug("Debug build: " + str(OS.is_debug_build()))
	
	if OS.is_debug_build():
		$TestHUD.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if OS.is_debug_build():
		_update_test_hud()
	
	
#Essa função deve ser usada para consumir eventos de atalho
func _shortcut_input(event: InputEvent):
	_debug_inputs(event)


#Função responsável por atalhos especificos da versão de debug
func _debug_inputs(event: InputEvent):
	#Só processa os eventos caso estiver no modo debug
	if OS.is_debug_build():
	
		#Sair do jogo
		if event.is_action_pressed("quit_game"):
			get_tree().quit(0)
	
	else: 
		pass

func _update_test_hud():
	var stamina: float = $SubViewportContainer/SubViewport/TestStage/Player.current_stamina
	var sprinting: bool = $SubViewportContainer/SubViewport/TestStage/Player.is_sprinting
	var colliding_object = $SubViewportContainer/SubViewport/TestStage/Player/CameraPivot/InteractRay.colliding_object
	var colliding_object_string: String = ""
	
	if colliding_object != null:
		colliding_object_string = str(colliding_object)
	else:
		colliding_object_string = "None"
	
	
	var test_string: String = ""
	
	test_string += "Stamina: " + str(stamina) + "\n"
	test_string += "Sprinting: " + str(sprinting) + "\n"
	test_string += "Ray Colliding Object: " + colliding_object_string + "\n"
	
	$TestHUD.update_test_info(test_string)
