extends CharacterBody2D
class_name inimigo

# ============ ATRIBUTOS ============
@export var vitalidade: int = 0
var vidaInicial: int
@export var defesa: int = 0
@export var forca: int = 0
@export var velocidade: float = 80.0
@export var inteligencia: int = 0
@export_enum("calmo", "normal", "bravo") var temperamento: String = "normal"

@export var cooldowns: Array[float] = [0.8, 1.2, 1.6]
@export var multiplicadores: Array[float] = [1.0, 1.3, 1.5]

@export_group("animacao")
@export var animacao_idle_baixo: StringName = &"idle_Front"
@export var animacao_idle_cima: StringName = &"idle_Botton"
@export var animacao_idle_esquerda: StringName = &"idle_Left"
@export var animacao_idle_direita: StringName = &"idle_Right"
@export var animacao_andar_baixo: StringName = &"walk_Front"
@export var animacao_andar_cima: StringName = &"walk_Botton"
@export var animacao_andar_esquerda: StringName = &"walk_Left"
@export var animacao_andar_direita: StringName = &"walk_Right"
@export var animacao_atacar_baixo: StringName = &"attack_Front"
@export var animacao_atacar_cima: StringName = &"attack_Botton"
@export var animacao_atacar_esquerda: StringName = &"attack_Left"
@export var animacao_atacar_direita: StringName = &"attack_Right"
@export var animacao_spawn: StringName = &"spawn"
@export var animacao_morte: StringName = &"dead"
@export var animacao_dano_baixo: StringName = &"damage_Front"
@export var animacao_dano_cima: StringName = &"damage_Botton"
@export var animacao_dano_esquerda: StringName = &"damage_Left"
@export var animacao_dano_direita: StringName = &"damage_Right"
@export_group("")

# Drops do inimigo
@export_group("drop")
@export var experiencia_min: int = 0
@export var experiencia_max: int = 0
@export var drops: Array[DropData] = []
@export_range(0.0, 1.0, 0.001) var chance_drop_item: float = 0.015
@export var garantir_drop_item: bool = false
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
var multiplicador_cooldown_ataque: float = 1.0
var inRange: bool = false
var direcao_animacao: Vector2 = Vector2.DOWN
var spawn_ativo := false
var tomando_dano := false
# ==================================


func _ready() -> void:
	add_to_group(&"inimigos")
	vitalidade = max(1, vitalidade * 5)

	_aplicar_temperamento()

	vidaInicial = vitalidade

	alcance.body_entered.connect(_on_area_body_entered)
	alcance.body_exited.connect(_on_area_body_exited)

	barraVida.max_value = vitalidade
	barraVida.value = vitalidade

	drops_escolhidos = _sortear_drops()

	animation_player.animation_finished.connect(_on_animacao_finalizada)
	_configurar_animacao()

func _aplicar_temperamento() -> void:
	match temperamento:
		"calmo":
			vitalidade = int(vitalidade * 1.4)
			defesa = int(defesa * 1.3)
			forca = int(forca * 0.75)
			velocidade = velocidade * 0.9

		"bravo":
			vitalidade = int(vitalidade * 0.75)
			defesa = int(defesa * 0.85)
			forca = int(forca * 1.4)
			velocidade = velocidade * 1.1

		"normal":
			pass

func _on_area_body_entered(body: Node) -> void:
	if body is protagonista:
		protagonista_ref = body
		inRange = true


func _on_area_body_exited(body: Node) -> void:
	if body == protagonista_ref:
		inRange = false


func _physics_process(delta: float) -> void:
	# O inimigo so comeca a agir depois da animacao de surgimento.
	if spawn_ativo:
		return

	# ============ SEM ALVO ============
	if protagonista_ref == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	# ================================

	# ============ DISTANCIA ============
	distancia = global_position.distance_to(protagonista_ref.global_position)
	# ==================================

	# ============ MOVIMENTO / PERSEGUICAO ============
	var pode_atacar := distancia <= distancia_ataque
	if not pode_atacar:
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
	if pode_atacar and cooldown <= 0.0:
		direcao_animacao = global_position.direction_to(protagonista_ref.global_position)
		cooldown = mecanicas.atacar(
			protagonista_ref,
			cooldowns,
			forca,
			multiplicadores
		) * multiplicador_cooldown_ataque
		_tocar_animacao(_animacao_por_direcao("atacar"))
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
	if not pode_atacar:
		move_and_slide()
	# ========================================

func _configurar_animacao() -> void:
	if animation_player.has_animation(animacao_spawn):
		spawn_ativo = true
		_tocar_animacao(animacao_spawn)
	else:
		_tocar_animacao(_animacao_por_direcao("idle"))

func _animacao_de_dano_por_direcao() -> StringName:
	var horizontal: bool = abs(direcao_animacao.x) > abs(direcao_animacao.y)

	if horizontal:
		if direcao_animacao.x < 0.0:
			return animacao_dano_esquerda
		return animacao_dano_direita

	if direcao_animacao.y < 0.0:
		return animacao_dano_cima

	return animacao_dano_baixo

func receber_dano(dano: float, direcao_ataque: Vector2 = Vector2.ZERO) -> void:
	if vitalidade <= 0:
		return

	# Atualiza a direção do inimigo em relação ao atacante
	if direcao_ataque != Vector2.ZERO:
		direcao_animacao = direcao_ataque.normalized()

	# Aplica o dano
	vitalidade = max(0, int(ceil(vitalidade - maxf(dano, 0.0))))

	# Atualiza a barra de vida
	barraVida.value = vitalidade

	# Marca que o inimigo tomou dano
	tomando_dano = true

	# Toca a animação de dano
	_tocar_animacao(_animacao_de_dano_por_direcao())

	# Reinicia o cooldown de cura
	cooldownDaCura = 15

	# Verifica morte
	if vitalidade <= 0:
		_processar_morte()


func _atualizar_animacao() -> void:
	# Mantém o ataque visível até o próximo ataque
	if cooldown > 0.0 and _animacao_de_ataque(animation_player.current_animation):
		return

	# Mantém a animação de dano até ela terminar
	if tomando_dano and _animacao_de_dano(animation_player.current_animation):
		return

	if velocity.length_squared() > 0.01:
		_tocar_animacao(_animacao_por_direcao("andar"))
	else:
		_tocar_animacao(_animacao_por_direcao("idle"))


func _animacao_por_direcao(estado: String) -> StringName:
	var horizontal :float= abs(direcao_animacao.x) > abs(direcao_animacao.y)

	if horizontal:
		if direcao_animacao.x < 0.0:
			return _nome_animacao(estado, animacao_idle_esquerda, animacao_andar_esquerda, animacao_atacar_esquerda)
		return _nome_animacao(estado, animacao_idle_direita, animacao_andar_direita, animacao_atacar_direita)

	if direcao_animacao.y < 0.0:
		return _nome_animacao(estado, animacao_idle_cima, animacao_andar_cima, animacao_atacar_cima)
	return _nome_animacao(estado, animacao_idle_baixo, animacao_andar_baixo, animacao_atacar_baixo)


func _nome_animacao(estado: String, idle: StringName, andar: StringName, atacar: StringName) -> StringName:
	match estado:
		"andar":
			return andar
		"atacar":
			return atacar
		_:
			return idle


func _animacao_de_ataque(nome_animacao: StringName) -> bool:
	return nome_animacao in [
		animacao_atacar_baixo,
		animacao_atacar_cima,
		animacao_atacar_esquerda,
		animacao_atacar_direita
	]

func _animacao_de_dano(nome_animacao: StringName) -> bool:
	return nome_animacao in [
		animacao_dano_baixo,
		animacao_dano_cima,
		animacao_dano_esquerda,
		animacao_dano_direita
	]


func _tocar_animacao(nome_animacao: StringName) -> void:
	if not animation_player.has_animation(nome_animacao):
		return

	if animation_player.current_animation != nome_animacao or not animation_player.is_playing():
		animation_player.play(nome_animacao)


func _on_animacao_finalizada(nome_animacao: StringName) -> void:
	if nome_animacao == animacao_spawn:
		spawn_ativo = false

	if _animacao_de_dano(nome_animacao):
		tomando_dano = false


# Devolve uma copia dos drops ja sorteados para o protagonista coletar.
func coletar_drops() -> Array[Dictionary]:
	return drops_escolhidos.duplicate(true)


# Executa a limpeza visual e desativa o inimigo quando a vida chega a zero.
func _processar_morte() -> void:
	if morte_processada:
		return

	morte_processada = true
	if animation_player.has_animation(animacao_morte):
		animation_player.stop()
		animation_player.seek(0.0, true)
		animation_player.play(animacao_morte)
		sprite.visible = true
	if protagonista_ref.dash_ativo:
		protagonista_ref.derrotados_utilizando_dash += 1
	if protagonista_ref.ataque_com == "true":
		protagonista_ref.inimigos_derrotados_usando_missil_reto += 1
	barraVida.visible = false
	alcance.queue_free()
	colision.queue_free()
	set_physics_process(false)
	set_process(false)


# Faz apenas uma tentativa rara por inimigo e limita a recompensa a um item.
func _sortear_drops() -> Array[Dictionary]:
	var sorteados: Array[Dictionary] = []
	var candidatos: Array[DropData] = []

	for drop in drops:
		if drop == null:
			continue

		var nome_drop := drop.nome.strip_edges()
		if nome_drop.is_empty():
			continue

		for _quantidade in range(maxi(drop.quantidade, 1)):
			candidatos.append(drop)

	if candidatos.is_empty():
		return sorteados

	if not garantir_drop_item and randf() > clampf(chance_drop_item, 0.0, 1.0):
		return sorteados

	var escolhido := candidatos.pick_random() as DropData
	var raridade_sorteada := escolhido.sortear_raridade_ponderada()
	if raridade_sorteada == -1:
		return sorteados

	_adicionar_drop_sorteado(
		sorteados,
		escolhido.nome.strip_edges(),
		raridade_sorteada
	)

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
