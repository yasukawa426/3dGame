extends RayCast3D

#Objeto que o raio esta colidindo atualemente, caso não estiver colidindo com nenhum tera nulo como valor
var colliding_object: Object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#Faz o raio não dectar o proprio jogador
	add_exception(owner)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		colliding_object = get_collider()
	else:
		colliding_object = null
