extends CharacterBody2D
class_name protagonista

# ============ REFERENCIAS ============
@export var alvos: Array[inimigo]
@onready var alcance: Area2D = $Area2D
@onready var barraVida: ProgressBar = $CanvasLayer/ProgressBar
@onready var sala: Node2D = $".."
@onready var barraCura: ProgressBar = $CanvasLayer/barraDeCura
@onready var barraExperiencia: ProgressBar = $CanvasLayer/barraDeExperiencia
@onready var label_nivel: Label = $CanvasLayer/labelNivel
@onready var label_moeda: Label = $CanvasLayer/containerMoedas/labelMoeda

@onready var Mecanicas = load("res://script/data/Mecanicas.gd")
@onready var mecanicas = Mecanicas.new()
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

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

const SPEED: float = 220
var ultima_direcao: String = "down"
var experienciaNecessaria = int(nivel * 1.2 + 40)

# Sistema de cura
var cooldownDaCura: float = 0.0

# sistema de drop
var experienciaDropada: int = 0
var dropsRecebido: bool = false
var drops_pendentes: Array[Dictionary] = []

# inventario
var inventario_ref: Inventario
# ===================================


# ============ MUSICA ============
var musica_normal = preload("res://res/sons/Musica_Sala.mp3") # <-- confere caminho
var musica_low_hp = preload("res://res/sons/Música_um_coração.mp3") # <-- cuidado com acento
var em_perigo: bool = false
# =================================


# ============ SFX ============
var som_ataque = preload("res://res/sons/Attack_Sound.mp3") # <-- confere caminho
var som_andar = preload("res://res/sons/Running_Sound.mp3") # <-- confere caminho

var tempo_passo: float = 0.0
var intervalo_passo: float = 0.7
# =================================


# ============ ATAQUE ============
var cooldowns: Array[float] = [1.0, 1.3, 1.7]
var multiplicadores: Array[float] = [1.0, 1.2, 1.5]
var cooldown: float = 0.0
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

	for alvo in alvos:
		experienciaDropada += randi_range(alvo.experiencia_min, alvo.experiencia_max)

	inventario_ref = get_tree().get_first_node_in_group("inventario_principal") as Inventario

	# 🎧 MUSICA INICIAL
	SoundManager.tocar_musica(musica_normal)


func _physics_process(delta: float) -> void:
	# ============ MOVIMENTO X ============
	var direction_x: float = Input.get_axis("ui_left", "ui_right")
	if direction_x != 0.0:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
	# =====================================

	# ============ MOVIMENTO Y ============
	var direction_y: float = Input.get_axis("ui_up", "ui_down")
	if direction_y != 0.0:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0.0, SPEED)
	# =====================================

	# ============ VERIFICAR MOVIMENTO ============
	var esta_andando = velocity.length() > 10
	atualizar_animacao(direction_x, direction_y)
	# =============================================

	# ============ ATAQUE ============
	for alvo in alvos:
		if Input.is_action_just_pressed("ui_attack") and cooldown <= 0.0:
			if alvo != null and alvo.inRange:
				cooldown = mecanicas.atacar(alvo, cooldowns, forca, multiplicadores)

				# 🎧 SOM DE ATAQUE
				SoundManager.tocar_sfx(som_ataque, 8)

				alvo.cooldownDaCura = 15
				if alvo.vitalidade <= 0:
					_acumular_drops_do_inimigo(alvo)
					alvos.erase(alvo)
					sala.move_child(alvo, 0)
				return
	# =================================

	# ============ COOLDOWN ============
	if cooldown > 0.0:
		cooldown -= delta
	# =================================

	# ============ CURAR ==============
	if Input.is_action_pressed("ui_healing") and cooldownDaCura <= 0 and vidaInicial > vitalidade:
		mecanicas.cura(self, 10 * 60 / (max(inteligencia / 20, 1)))
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
	if experiencia >= experienciaNecessaria:
		mecanicas.subirNivel(self)
		label_nivel.text = str("Lv. ", nivel)
	barraExperiencia.value = experiencia
	# ==================================

	# ============ MOVIMENTO FINAL ============
	move_and_slide()
	# ========================================

	# ============ SOM DE PASSO ============
	if esta_andando:
		SoundManager.iniciar_passo(som_andar)
	else:
		SoundManager.parar_passo()
	# ======================================
	

	# 🎧 VERIFICAR VIDA (MUSICA)
	verificar_vida()


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


func _adicionar_drop_pendente(nome: String, raridade: int, quantidade: int) -> void:
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
		inventario_ref = get_tree().get_first_node_in_group("inventario_principal") as Inventario

	if inventario_ref == null:
		return

	for item in drops_pendentes:
		inventario_ref.adicionar_item(
			str(item.get("nome", "")),
			int(item.get("raridade", ItensData.Raridade.COMUM)),
			int(item.get("quantidade", 1))
		)

	drops_pendentes.clear()

func atualizar_animacao(direction_x: float, direction_y: float) -> void:

	if direction_x == 0 and direction_y == 0:

		match ultima_direcao:
			"up":
				anim.play("idle_up")

			"down":
				anim.play("idle_down")

			"left":
				anim.play("idle_left")

			"right":
				anim.play("idle_right")

	else:

		if abs(direction_x) > abs(direction_y):

			if direction_x > 0:
				anim.play("walk_right")
				ultima_direcao = "right"

			else:
				anim.play("walk_left")
				ultima_direcao = "left"

		else:

			if direction_y > 0:
				anim.play("walk_down")
				ultima_direcao = "down"

			else:
				anim.play("walk_up")
				ultima_direcao = "up"

func _on_area_2d_body_entered(_body: Node) -> void:
	pass
