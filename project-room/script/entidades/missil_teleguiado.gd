extends Missil
class_name MissilTeleguiado

@export var velocidade_teleguiado: float = 300.0
@export var forca_perseguicao: float = 8.0
@export var distancia_maxima_busca: float = 500.0

var alvo: Node2D = null


func _ready() -> void:
	super._ready()

	_encontrar_alvo()


func _physics_process(delta: float) -> void:
	if explodiu:
		return

	if alvo == null or not is_instance_valid(alvo):
		_encontrar_alvo()

	if alvo != null:
		_perseguir_alvo(delta)
	else:
		global_position += direcao * velocidade_teleguiado * delta


func _encontrar_alvo() -> void:
	var inimigos := get_tree().get_nodes_in_group("inimigos")

	var distancia_menor := distancia_maxima_busca
	var alvo_encontrado: Node2D = null

	for inimigo in inimigos:
		if not inimigo is Node2D:
			continue

		if not is_instance_valid(inimigo):
			continue

		var distancia := global_position.distance_to(inimigo.global_position)

		if distancia < distancia_menor:
			distancia_menor = distancia
			alvo_encontrado = inimigo

	alvo = alvo_encontrado


func _perseguir_alvo(delta: float) -> void:
	var direcao_alvo := global_position.direction_to(alvo.global_position)

	# Faz a direção atual girar gradualmente em direção ao inimigo.
	direcao = direcao.lerp(
		direcao_alvo,
		forca_perseguicao * delta
	).normalized()

	global_position += direcao * velocidade_teleguiado * delta

	# Faz o sprite apontar para a direção do movimento.
	rotation = direcao.angle()
