extends CharacterBody2D
class_name inimigo

# ============ ATRIBUTOS ============
@export var vitalidade: int = 0
var vidaInicial: int
@export var defesa: int = 0
@export var forca: int = 0
@export var velocidade: float = 120.0
@export var inteligencia: int = 0
@export var temperamento: String

@export var cooldowns: Array[float] = [0.8, 1.2, 1.6]
@export var multiplicadores: Array[float] = [1.0, 1.3, 1.5]

# Distância mínima para parar e bater
@export var distancia_ataque: float = 86
var distancia: float

# Sistema de cura
var tomouDano: bool = false
var cooldownDaCura: float = 0.0
# ===================================


# ============ REFERÊNCIAS ============
@export var protagonista_ref: protagonista
@onready var meshInstance : MeshInstance2D = $MeshInstance2D
@onready var alcance: Area2D = $Area2D
@onready var barraVida : ProgressBar = $ProgressBar
@onready var colision : CollisionShape2D = $CollisionShape2D

const Mecanicas = preload("res://script/Mecanicas.gd")
var mecanicas = Mecanicas.new()
# =====================================


# ============ CONTROLE ============
var cooldown: float = 0.0
var inRange: bool = false
# ==================================


func _ready() -> void:
	randomize()
	vitalidade *= 5
	vidaInicial = vitalidade
	defesa *= 2

	# ============ SINAIS DA ÁREA ============
	alcance.body_entered.connect(_on_area_body_entered)
	alcance.body_exited.connect(_on_area_body_exited)
	# =======================================
	
	# ============ BARRA DE VIDA ==============
	barraVida.max_value = vitalidade
	barraVida.value = vitalidade
	# =========================================


func _on_area_body_entered(body: Node) -> void:
	if body is protagonista:
		protagonista_ref = body
		inRange = true


func _on_area_body_exited(body: Node) -> void:
	if body == protagonista_ref:
		inRange = false

func _physics_process(delta: float) -> void:
	# ============ SEM ALVO ============
	if protagonista_ref == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	# ================================
	
	
	# ======== AÇÕES AO MORRER ========
	if vitalidade == 0:
		meshInstance.modulate = Color(0.81, 0.0, 0.228)
		barraVida.queue_free()
		alcance.queue_free()
		colision.queue_free()
		set_physics_process(false)
		set_process(false)
	#==================================
	

	# ============ DISTÂNCIA ============
	distancia = global_position.distance_to(protagonista_ref.global_position)
	# ==================================
	

	# ============ MOVIMENTO / PERSEGUIÇÃO ============
	if !inRange and distancia > distancia_ataque - 1:
		var direcao: Vector2 = global_position.direction_to(protagonista_ref.global_position)
		direcao.x = mecanicas.ajustar_eixo(direcao.x)
		direcao.y = mecanicas.ajustar_eixo(direcao.y)
		
		velocity = direcao * velocidade
	else:
		velocity.x = move_toward(velocity.x, 0.0, velocidade)
		velocity.y = move_toward(velocity.y, 0.0, velocidade)
	# ================================================


	# ============ ATAQUE ============
	if inRange and distancia <= distancia_ataque and cooldown <= 0.0:
		cooldown = mecanicas.atacar(protagonista_ref, cooldowns, forca, multiplicadores)

	elif cooldown > 0.0:
		cooldown -= delta
	# =================================
	
	# ============ CURAR ==============
	if vitalidade < vidaInicial and !tomouDano:
		tomouDano = true
		cooldownDaCura += 15
	elif vitalidade == vidaInicial:
		tomouDano = false
	if tomouDano and cooldownDaCura <= 0 and vitalidade < vidaInicial:
		mecanicas.cura(self, 7)
		if vitalidade > vidaInicial:
			vitalidade = vidaInicial
	elif cooldownDaCura > 0:
		cooldownDaCura -= delta
	print(cooldownDaCura)
	# =================================
	

	# ============ MOVIMENTO FINAL ============
	if !inRange:
		move_and_slide()
	# ========================================
