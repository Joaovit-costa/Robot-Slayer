extends Control
class_name Missil

@export var velocidade: float = 400.0
@export var dano: int = 10
@export var dano_explosao: int = 10
@export var raio_explosao: float = 100.0

var direcao: Vector2 = Vector2.ZERO
var explodiu: bool = false
var player: protagonista


func _ready() -> void:
	$Panel/Area2D.body_entered.connect(_on_area_2d_body_entered)

	# Configura a área da explosão.
	var collision_explosao := $AreaExplosao/CollisionShape2D

	if collision_explosao.shape is CircleShape2D:
		collision_explosao.shape.radius = raio_explosao

	z_index = 203


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		explodir()
	if explodiu:
		return

	global_position += direcao * velocidade * delta


func configurar(direcao_missil: Vector2, dano_missil: int, jogador: protagonista) -> void:
	direcao = direcao_missil.normalized()
	dano = dano_missil
	dano_explosao = dano_missil
	player = jogador

	rotation = direcao.angle()


func _on_area_2d_body_entered(corpo: Node2D) -> void:
	if explodiu or not is_instance_valid(player):
		queue_free()
		return

	# Se atingiu um inimigo, causa o dano direto
	# e depois explode.
	if corpo.is_in_group("inimigos"):
		if corpo.has_method("receber_dano"):
			player.ataque_com = "true"
			corpo.receber_dano(dano)
			if corpo.vitalidade <= 0:
				player._acumular_drops_do_inimigo(corpo)
				player.alvos.erase(corpo)
				var sala_do_alvo := corpo.get_parent()
				if sala_do_alvo != null:
					sala_do_alvo.move_child(corpo, 1)
		
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
			player.ataque_com = "true"
			inimigo.receber_dano(dano_explosao)
			if inimigo.vitalidade <= 0:
				player._acumular_drops_do_inimigo(inimigo)
				player.alvos.erase(inimigo)
				var sala_do_alvo := inimigo.get_parent()
				if sala_do_alvo != null:
					sala_do_alvo.move_child(inimigo, 1)
	
	if is_instance_valid(player):
		player.ataque_com = "false"
	queue_free()
