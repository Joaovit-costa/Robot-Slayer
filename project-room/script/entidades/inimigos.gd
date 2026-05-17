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

@export_group("animacao")
@export var animacao_idle_down: StringName = &"idle_down"
@export_group("")

# Drops do inimigo
@export_group("drop")
@export var experiencia_min: int = 0
@export var experiencia_max: int = 0
@export var drops: Array[DropData] = []
@export_group("")
var drops_escolhidos: Array[Dictionary] = []

# Distancia minima para parar e bater
@export var distancia_ataque: float = 86
var distancia: float


# Sistema de cura
var tomouDano: bool = false
var cooldownDaCura: float = 0.0
var morte_processada := false
# ===================================


# ============ REFERENCIAS ============
@export var protagonista_ref: protagonista
@onready var sprite: Sprite2D = $Sprite2D
@onready var alcance: Area2D = $Sprite2D/Area2D
@onready var barraVida: ProgressBar = $ProgressBar
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@onready var Mecanicas = load("res://script/data/Mecanicas.gd")
@onready var mecanicas = Mecanicas.new()
# =====================================


# ============ CONTROLE ============
var cooldown: float = 0.0
var inRange: bool = false
var direcao_animacao: Vector2 = Vector2.DOWN
# ==================================


func _ready() -> void:
	randomize()
	vitalidade *= 5
	vidaInicial = vitalidade
	defesa *= 2

	# ============ SINAIS DA AREA ============
	alcance.body_entered.connect(_on_area_body_entered)
	alcance.body_exited.connect(_on_area_body_exited)
	# =======================================

	# ============ BARRA DE VIDA ==============
	barraVida.max_value = vitalidade
	barraVida.value = vitalidade
	# =========================================

	# ======= Definir os itens dropados =======
	drops_escolhidos = _sortear_drops()
	# =========================================
	
	# ============ ANIMACAO ============
	_configurar_animacao()
	# ==================================


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

	# ======== ACOES AO MORRER ========
	if vitalidade <= 0:
		_processar_morte()
		return
	# =================================

	# ============ DISTANCIA ============
	distancia = global_position.distance_to(protagonista_ref.global_position)
	# ==================================

	# ============ MOVIMENTO / PERSEGUICAO ============
	if not inRange and distancia > distancia_ataque - 1:
		var direcao: Vector2 = global_position.direction_to(protagonista_ref.global_position)
		direcao.x = mecanicas.ajustar_eixo(direcao.x)
		direcao.y = mecanicas.ajustar_eixo(direcao.y)
		velocity = direcao * velocidade
		direcao_animacao = direcao
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
	if vitalidade < vidaInicial and not tomouDano:
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
	# =================================
	
	# ============ ANIMACAO ============
	_atualizar_animacao()
	# ==================================


	# ============ MOVIMENTO FINAL ============
	if not inRange:
		move_and_slide()
	# ========================================

# Por enquanto o inimigo so tem a animacao idle_down.
# Quando as animacoes Walk/Attack e outras direcoes existirem, a troca de estados
# pode voltar a ser feita pelo AnimationTree igual ao protagonista.
func _configurar_animacao() -> void:
	_tocar_idle_down()


func _atualizar_animacao() -> void:
	_tocar_idle_down()


func _tocar_idle_down() -> void:
	if not animation_player.has_animation(animacao_idle_down):
		return

	if animation_player.current_animation != animacao_idle_down or not animation_player.is_playing():
		animation_player.play(animacao_idle_down)


# Devolve uma copia dos drops ja sorteados para o protagonista coletar.
func coletar_drops() -> Array[Dictionary]:
	return drops_escolhidos.duplicate(true)


# Executa a limpeza visual e desativa o inimigo quando a vida chega a zero.
func _processar_morte() -> void:
	if morte_processada:
		return

	morte_processada = true
	sprite.modulate = Color(0.81, 0.0, 0.228)
	barraVida.queue_free()
	alcance.queue_free()
	colision.queue_free()
	set_physics_process(false)
	set_process(false)


# Sorteia todos os itens cadastrados usando quantidade como numero de tentativas.
func _sortear_drops() -> Array[Dictionary]:
	var sorteados: Array[Dictionary] = []

	for drop in drops:
		if drop == null:
			continue

		var nome_drop := drop.nome.strip_edges()
		if nome_drop.is_empty():
			continue

		for _tentativa in range(max(0, drop.quantidade)):
			var raridade_sorteada := drop.sortear_raridade()
			if raridade_sorteada == -1:
				continue
			_adicionar_drop_sorteado(sorteados, nome_drop, raridade_sorteada)

	return sorteados


# Junta itens iguais da mesma raridade no registro final de drops do inimigo.
func _adicionar_drop_sorteado(sorteados: Array[Dictionary], nome_drop: String, raridade: int) -> void:
	for item in sorteados:
		if (
			str(item.get("nome", "")) == nome_drop
			and int(item.get("raridade", ItensData.Raridade.COMUM)) == raridade
		):
			item["quantidade"] = int(item.get("quantidade", 0)) + 1
			return

	sorteados.append({
		"nome": nome_drop,
		"quantidade": 1,
		"raridade": raridade
	})
