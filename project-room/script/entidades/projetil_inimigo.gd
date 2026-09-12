extends Area2D

const TEXTURA_EXPLOSAO: Texture2D = preload(
	"res://res/design/Design-Robot Slayer/sprits/explosão-new.png"
)
const QUANTIDADE_QUADROS_EXPLOSAO := 10
const TAMANHO_QUADRO_EXPLOSAO := Vector2(50.0, 50.0)
const CAMADA_PLAYER := 2
const Z_INDEX_EXPLOSAO := 500

var direcao: Vector2 = Vector2.ZERO
var velocidade: float = 300.0
var alcance: float = 500.0
var distancia_percorrida: float = 0.0
var dano: int = 0
@export var raio_explosao: float = 50.0
@export var escala_explosao: float = 1.65

var explodiu := false
var forma_explosao := CircleShape2D.new()

@onready var colisor: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	forma_explosao.radius = raio_explosao
	_configurar_animacao_explosao()
	sprite.play(&"default")


func configurar(nova_direcao: Vector2, nova_velocidade: float, novo_alcance: float, forca_inimigo: int) -> void:
	direcao = nova_direcao.normalized()
	velocidade = nova_velocidade
	alcance = novo_alcance
	dano = forca_inimigo
	
	rotation = direcao.angle()


func _physics_process(delta: float) -> void:
	if explodiu:
		return

	var movimento: Vector2 = direcao * velocidade * delta
	
	global_position += movimento
	distancia_percorrida += movimento.length()
	
	if distancia_percorrida >= alcance:
		explodir()


func _on_body_entered(body: Node) -> void:
	# O projétil nasce sobre o inimigo que o disparou. Como os inimigos também
	# compartilham uma camada com o cenário, eles precisam ser ignorados aqui.
	if body.is_in_group(&"inimigos"):
		return

	explodir()


func explodir() -> void:
	if explodiu:
		return

	explodiu = true
	set_physics_process(false)
	set_deferred("monitoring", false)
	colisor.set_deferred("disabled", true)

	rotation = 0.0
	sprite.scale = Vector2.ONE * escala_explosao
	# Usa Z absoluto: cenário e entidades chegam a aproximadamente 410,
	# enquanto transições e interfaces permanecem acima desta camada.
	sprite.z_as_relative = false
	sprite.z_index = Z_INDEX_EXPLOSAO
	sprite.play(&"Explosao")
	call_deferred("_aplicar_dano_da_explosao")

	await sprite.animation_finished
	queue_free()


func _aplicar_dano_da_explosao() -> void:
	if not is_inside_tree():
		return

	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma_explosao
	consulta.transform = Transform2D(0.0, global_position)
	consulta.collision_mask = CAMADA_PLAYER
	consulta.collide_with_areas = false
	consulta.collide_with_bodies = true

	for resultado in get_world_2d().direct_space_state.intersect_shape(
		consulta,
		8
	):
		var player := resultado.get("collider") as protagonista
		if player != null:
			player.receber_dano(dano)
			return


func _configurar_animacao_explosao() -> void:
	# Cada projétil recebe sua própria biblioteca para não alterar os demais
	# enquanto eles ainda reproduzem a animação de voo.
	var animacoes := sprite.sprite_frames.duplicate(true) as SpriteFrames
	sprite.sprite_frames = animacoes

	if animacoes.has_animation(&"Explosao"):
		return

	animacoes.add_animation(&"Explosao")
	animacoes.set_animation_loop(&"Explosao", false)
	animacoes.set_animation_speed(&"Explosao", 12.0)

	for indice in range(QUANTIDADE_QUADROS_EXPLOSAO):
		var quadro := AtlasTexture.new()
		quadro.atlas = TEXTURA_EXPLOSAO
		quadro.region = Rect2(
			Vector2(TAMANHO_QUADRO_EXPLOSAO.x * indice, 0.0),
			TAMANHO_QUADRO_EXPLOSAO
		)
		animacoes.add_frame(&"Explosao", quadro)
