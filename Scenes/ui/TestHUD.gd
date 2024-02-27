extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Atualiza a mensagem de stamina
func update_stamina(stamina: float):
	$StaminaLabel.text = "Stamina: " + str(stamina)

func update_sprinting(sprinting: bool):
	$SprintingLabel.text = "Sprinting: " + str(sprinting)
