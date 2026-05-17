extends CharacterBody2D
class_name protagonista

# ============ REFERENCIAS ============
@export var alvos: Array[inimigo]

@onready var alcance: Area2D = $Sprite2D/Area2D
@onready var hitbox_ataque: CollisionShape2D = $Sprite2D/Area2D/CollisionShape2D
@onready var barraVida: ProgressBar = $CanvasLayer/ProgressBar
@onready var sala: Node2D = $".."
@onready var barraCura: ProgressBar = $CanvasLayer/barraDeCura
@onready var barraExperiencia: ProgressBar = $CanvasLayer/barraDeExperiencia
@onready var label_nivel: Label = $CanvasLayer/labelNivel
@onready var label_moeda: Label = $CanvasLayer/containerMoedas/labelMoeda

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

@onready var Mecanicas = load("res://script/data/Mecanicas.gd")
@onready var mecanicas = Mecanicas.new()
# =====================================


# ============ ATRIBUTOS ============
var vitalidade: int = 6
var vidaInicial: int
var defesa: int = 2
var forca: int = 5
var inteligencia: int = 4
var pontosExperiencia: int = 0
var experiencia: int = 0
var nivel: int = 1
var moedas: int = 0
var pontosStatus: int = 0

const SPEED: float = 220

var ultima_direcao: String = "down"
var direcao_animacao: Vector2 = Vector2.DOWN
var direcao_ataque: Vector2 = Vector2.DOWN
var posicao_alcance_original: Vector2 = Vector2.ZERO

var experienciaNecessaria = int(nivel * 1.2 + 40)

# Sistema de cura
var cooldownDaCura: float = 0.0

# Sistema de ataque
var atacando: bool = false
var tempo_ataque_restante: float = 0.0
var indice_ataque_atual: int = 0
var inimigos_acertados_no_ataque: Array[inimigo] = []

# sistema de drop
var experienciaDropada: int = 0
var dropsRecebido: bool = false
var drops_pendentes: Array[Dictionary] = []

# inventario
var inventario_ref: Inventario
# ===================================


# ============ MUSICA ============
var musica_normal = preload("res://res/sons/Musica_Ambiente_1.mp3")
var musica_low_hp = preload("res://res/sons/Música_um_coração.mp3")


var em_perigo: bool = false
# =================================


# ============ SFX ============
var som_ataque = preload("res://res/sons/Som_Ataque.mp3")
var som_andar = preload("res://res/sons/Som andando.mp3")
# =================================

# ============ ATAQUE ============
var cooldowns: Array[float] = [1.0, 1.3, 1.7]
var multiplicadores: Array[float] = [1.0, 1.2, 1.5]
var cooldown: float = 0.0
const DURACAO_ANIMACAO_ATAQUE: float = 0.9
# =================================


func _ready() -> void:

	randomize()

	vitalidade *= 5
	vidaInicial = vitalidade

	defesa *= 3

	barraVida.max_value = vitalidade
	barraVida.value = vitalidade

	barraExperiencia.max_value = experienciaNecessaria
	barraExperiencia.value = experiencia

	label_nivel.text = "Lv. " + str(nivel)
	label_moeda.text = str(moedas)

	barraCura.max_value = 10 * 60 / max(inteligencia / 20, 1)
	barraCura.value = cooldownDaCura
	
	if alvos[0] != null:
		for alvo in alvos:
			experienciaDropada += randi_range(
				alvo.experiencia_min,
				alvo.experiencia_max
			)

	inventario_ref = get_tree().get_first_node_in_group(
		"inventario_principal"
	) as Inventario

	# ============ ANIMACAO ============
	animation_tree.active = true
	posicao_alcance_original = alcance.position
	hitbox_ataque.disabled = true
	# ==================================

	# 🎧 MUSICA INICIAL
	SoundManager.tocar_musica(musica_normal)
	
	call_deferred("_sincronizar_menu_status")


func _physics_process(delta: float) -> void:
	# ============ MOVIMENTO ============
	var direcao = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	if direcao != Vector2.ZERO:
		direcao = direcao.normalized()

	velocity = direcao * SPEED
	# ===================================

	# ============ DIRECAO ANIMACAO ============
	if velocity.length() > 0:
		direcao_animacao = velocity.normalized()
	# ==========================================
	
# ============ ATAQUE ============
	if Input.is_action_just_pressed("ui_attack") and cooldown <= 0.0 and not atacando:
		iniciar_ataque()
		
		
	if atacando:
		tempo_ataque_restante -= delta
		if not hitbox_ataque.disabled:
			executar_ataque()
		
		if tempo_ataque_restante <= 0.0:	
			finalizar_ataque()
	# =================================
	
	
	# ============ COOLDOWN ============
	if cooldown > 0.0:
		cooldown -= delta
	# =================================

	# ============ CURAR ==============
	if (
		Input.is_action_pressed("ui_healing")
		and cooldownDaCura <= 0
		and vidaInicial > vitalidade
	):

		mecanicas.cura(
			self,
			10 * 60 / (max(inteligencia / 20, 1))
		)

		barraCura.max_value = cooldownDaCura

		if vitalidade > vidaInicial:
			vitalidade = vidaInicial

	elif cooldownDaCura > 0:

		cooldownDaCura -= delta
		barraCura.value = cooldownDaCura
	# =================================
	
	# ===== AO MATAR TODOS DA SALA =====
	if len(alvos) <= 0 and not dropsRecebido:

		experiencia += experienciaDropada

		var moedasDropadas = randi_range(5, 15)
		moedas += moedasDropadas

		label_moeda.text = str(moedas)

		_entregar_drops_pendentes()

		dropsRecebido = true
	# ==================================


	# ========= SUBIR DE NIVEL =========
	var subiu_de_nivel : bool = false
	while experiencia >= experienciaNecessaria and experienciaNecessaria > 0:

		mecanicas.subirNivel(self)
		subiu_de_nivel = true
	
	if subiu_de_nivel:
		label_nivel.text = str("Lv. ", nivel)
		_sincronizar_menu_status()
	barraExperiencia.value = experiencia
	# ==================================


	# ============ ANIMACAO ============
	if atacando:
		animation_state.travel("Attack")

	elif velocity.length() > 5:
		animation_state.travel("Walk")

	else:
		animation_state.travel("Idle")

	animation_tree.set(
		"parameters/Idle/blend_position",
		direcao_animacao
	)

	animation_tree.set(
		"parameters/Walk/blend_position",
		direcao_animacao
	)

	animation_tree.set(
		"parameters/Attack/blend_position",
		direcao_ataque if atacando else direcao_animacao
	)
	# ==================================


	# ============ MOVIMENTO FINAL ============
	move_and_slide()
	# ========================================


	
	# ============ SOM DE PASSO ============
	if velocity.length() > 5 and not atacando:
		SoundManager.iniciar_passo(som_andar)
	else:
		SoundManager.parar_passo()
	# ======================================


	# 🎧 VERIFICAR VIDA (MUSICA)
	verificar_vida()





func _sincronizar_menu_status() -> void:
	var menus_status := get_tree().get_nodes_in_group("menu_status")

	for menu in menus_status:
		if menu.has_method("configurar"):
			menu.configurar(self)
		elif menu.has_method("atualizar_menu_status"):
			menu.atualizar_menu_status()
			
			
func verificar_vida():

	var vida_percent = float(vitalidade) / float(vidaInicial)

	if vida_percent <= 0.2 and not em_perigo:

		em_perigo = true
		SoundManager.tocar_musica(musica_low_hp)

	elif vida_percent > 0.2 and em_perigo:

		em_perigo = false
		SoundManager.tocar_musica(musica_normal)


func _acumular_drops_do_inimigo(alvo: inimigo) -> void:

	if alvo == null:
		return

	for item in alvo.coletar_drops():

		_adicionar_drop_pendente(
			str(item.get("nome", "")),
			int(item.get("raridade", ItensData.Raridade.COMUM)),
			int(item.get("quantidade", 1))
		)


func _adicionar_drop_pendente(
	nome: String,
	raridade: int,
	quantidade: int
) -> void:

	for item in drops_pendentes:

		if (
			str(item.get("nome", "")) == nome
			and int(item.get("raridade", ItensData.Raridade.COMUM)) == raridade
		):

			item["quantidade"] = int(item.get("quantidade", 0)) + quantidade
			return

	drops_pendentes.append({
		"nome": nome,
		"raridade": raridade,
		"quantidade": quantidade
	})


func _entregar_drops_pendentes() -> void:

	if inventario_ref == null:
		inventario_ref = get_tree().get_first_node_in_group(
			"inventario_principal"
		) as Inventario

	if inventario_ref == null:
		return

	for item in drops_pendentes:

		inventario_ref.adicionar_item(
			str(item.get("nome", "")),
			int(item.get("raridade", ItensData.Raridade.COMUM)),
			int(item.get("quantidade", 1))
		)

	drops_pendentes.clear()


func iniciar_ataque() -> void:
	atacando = true
	direcao_ataque = direcao_animacao
	_congelar_alcance_do_ataque()
	tempo_ataque_restante = DURACAO_ANIMACAO_ATAQUE
	indice_ataque_atual = randi() % cooldowns.size()
	cooldown = cooldowns[indice_ataque_atual]
	inimigos_acertados_no_ataque.clear()
	hitbox_ataque.set_deferred("disabled", true)

	# 🎧 SOM DE ATAQUE
	SoundManager.tocar_sfx(som_ataque, 8)


func executar_ataque() -> void:
	for body in alcance.get_overlapping_bodies():
		_aplicar_dano_da_hitbox(body)


func finalizar_ataque() -> void:
	atacando = false
	tempo_ataque_restante = 0.0
	inimigos_acertados_no_ataque.clear()
	hitbox_ataque.set_deferred("disabled", true)
	_restaurar_alcance_do_ataque()


func _congelar_alcance_do_ataque() -> void:
	# Mantem a hitbox do golpe no ponto em que o ataque comecou.
	# Assim o jogador pode andar sem arrastar a area ativa do ataque.
	var posicao_alcance_global := alcance.global_position
	alcance.set_as_top_level(true)
	alcance.global_position = posicao_alcance_global


func _restaurar_alcance_do_ataque() -> void:
	# Depois do ataque, a hitbox volta a acompanhar o Sprite2D normalmente.
	alcance.set_as_top_level(false)
	alcance.position = posicao_alcance_original
	
	
func _aplicar_dano_da_hitbox(body: Node) -> void:
	if not atacando:
		return

	if hitbox_ataque.disabled:
		return

	var alvo := body as inimigo
	if alvo == null:
		return

	if alvo not in alvos or alvo in inimigos_acertados_no_ataque:
		return

	inimigos_acertados_no_ataque.append(alvo)

	var dano: float = max(
		forca * multiplicadores[indice_ataque_atual] - alvo.defesa,
		1
	)
	alvo.vitalidade = max(alvo.vitalidade - dano, 0)
	alvo.barraVida.value = alvo.vitalidade
	alvo.cooldownDaCura = 15

	if alvo.vitalidade <= 0:
		_acumular_drops_do_inimigo(alvo)
		alvos.erase(alvo)
		sala.move_child(alvo, 0)


func _on_area_2d_body_entered(body: Node) -> void:
	_aplicar_dano_da_hitbox(body)
