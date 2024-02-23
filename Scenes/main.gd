extends Node

#Esse script contem alguns códigos gerais do mundo, q devem estar presentes em todas as cenas.
#Por enquanto temos só os shortcuts do modo debug.

# Called when the node enters the scene tree for the first time.
func _ready():	
	print_debug("Debug build: " + str(OS.is_debug_build()))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
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
