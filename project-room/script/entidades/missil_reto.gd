extends Control
class_name Missil

@export var velocidade: float = 400.0
@export var dano: int = 10
@export var dano_explosao: int = 10
@export var raio_explosao: float = 100.0

var direcao: Vector2 = Vector2.ZERO
var explodiu: bool = false


func _ready() -> void:
	$Panel/Area2D.body_entered.connect(_on_area_2d_body_entered)

	# Configura a área da explosão.
	var collision_explosao := $AreaExplosao/CollisionShape2D

	if collision_explosao.shape is CircleShape2D:
		collision_explosao.shape.radius = raio_explosao

	z_index = 90


func _physics_process(delta: float) -> void:
	if explodiu:
		return

	position += direcao * velocidade * delta


func configurar(direcao_missil: Vector2, dano_missil: int) -> void:
	direcao = direcao_missil.normalized()
	dano = dano_missil
	dano_explosao = dano_missil

	rotation = direcao.angle()


func _on_area_2d_body_entered(corpo: Node2D) -> void:
	if explodiu:
		return

	# Se atingiu um inimigo, causa o dano direto
	# e depois explode.
	if corpo.is_in_group("inimigos"):
		if corpo.has_method("receber_dano"):
			corpo.receber_dano(dano)

		explodir()
		return

	# Se atingiu uma parede, explode.
	explodir()
	return


func explodir() -> void:
	if explodiu:
		return

	explodiu = true

	# Impede que o míssil continue se movimentando.
	set_physics_process(false)

	# Ativa temporariamente a área da explosão.
	var area_explosao: Area2D = $AreaExplosao
	area_explosao.monitoring = true

	# Espera a física atualizar os corpos detectados.
	await get_tree().physics_frame

	var inimigos_atingidos := area_explosao.get_overlapping_bodies()

	for inimigo in inimigos_atingidos:
		if not inimigo.is_in_group("inimigos"):
			continue

		if inimigo.has_method("receber_dano"):
			inimigo.receber_dano(dano_explosao)

	queue_free()
