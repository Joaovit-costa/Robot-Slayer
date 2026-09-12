extends Control
class_name Missil

const Z_INDEX_EXPLOSAO := 500

@export var velocidade: float = 400.0
@export var dano: int = 10
@export var dano_explosao: int = 10
@export var raio_explosao: float = 100.0

var direcao: Vector2 = Vector2.ZERO
var explodiu: bool = false
var player: protagonista

@onready var area_impacto: Area2D = $Panel/Area2D
@onready var area_explosao: Area2D = $AreaExplosao
@onready var colisor_impacto: CollisionShape2D = $Panel/Area2D/CollisionShape2D
@onready var colisor_explosao: CollisionShape2D = $AreaExplosao/CollisionShape2D
@onready var sprite_animado: AnimatedSprite2D = $Panel as AnimatedSprite2D


func _ready() -> void:
	area_impacto.body_entered.connect(_on_area_2d_body_entered)
	area_explosao.monitoring = false

	# Configura a área da explosão.
	if colisor_explosao.shape is CircleShape2D:
		colisor_explosao.shape.radius = raio_explosao

	if sprite_animado != null:
		sprite_animado.play(&"default")

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
	if explodiu:
		return

	# Qualquer corpo presente na máscara do míssil (cenário ou inimigo)
	# provoca a explosão.
	explodir()


func explodir() -> void:
	if explodiu:
		return

	explodiu = true

	# Congela o míssil e impede novos impactos durante a explosão.
	set_physics_process(false)
	area_impacto.set_deferred("monitoring", false)
	colisor_impacto.set_deferred("disabled", true)

	# Inicia o efeito visual no exato ponto do impacto.
	if sprite_animado != null:
		rotation = 0.0
		# O cenário usa uma base de Z 200 e sobreposições que chegam a 410.
		# O Z absoluto mantém a explosão acima do mundo sem cobrir a interface.
		sprite_animado.z_as_relative = false
		sprite_animado.z_index = Z_INDEX_EXPLOSAO
		sprite_animado.play(&"Explosao")

	# A consulta é adiada para fora do sinal de colisão, quando o espaço de
	# física pode ser consultado com segurança.
	call_deferred("_atingir_alvos_na_explosao")

	# Mantém o nó vivo até todos os quadros da explosão terminarem.
	if sprite_animado != null:
		await sprite_animado.animation_finished
	else:
		await get_tree().create_timer(0.15).timeout

	queue_free()


func _atingir_alvos_na_explosao() -> void:
	if not is_inside_tree() or colisor_explosao.shape == null:
		return

	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = colisor_explosao.shape
	consulta.transform = colisor_explosao.global_transform
	consulta.collision_mask = area_explosao.collision_mask
	consulta.collide_with_areas = false
	consulta.collide_with_bodies = true

	var alvos_atingidos: Array[inimigo] = []
	for resultado in get_world_2d().direct_space_state.intersect_shape(
		consulta,
		64
	):
		var alvo := resultado.get("collider") as inimigo
		if (
			alvo == null
			or alvo.vitalidade <= 0
			or alvo in alvos_atingidos
		):
			continue

		alvos_atingidos.append(alvo)
		_aplicar_dano_da_explosao(alvo)


func _aplicar_dano_da_explosao(alvo: inimigo) -> void:
	if not is_instance_valid(player):
		return

	player.ataque_com = "true"
	var direcao_impacto := alvo.global_position.direction_to(global_position)
	alvo.receber_dano(dano_explosao, direcao_impacto)
	player.ataque_com = "false"

	if alvo.vitalidade > 0:
		return

	player._acumular_drops_do_inimigo(alvo)
	player.alvos.erase(alvo)
	var sala_do_alvo := alvo.get_parent()
	if sala_do_alvo != null:
		sala_do_alvo.move_child(alvo, 1)
