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

# ===== MENU STATUS =====
@onready var menu_status = get_tree().get_first_node_in_group("menu_status")
# =======================

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
var experienciaNecessaria = int(nivel * 1.2 + 40)

var cooldownDaCura: float = 0.0

# drops
var experienciaDropada: int = 0
var dropsRecebido: bool = false
var drops_pendentes: Array[Dictionary] = []

var inventario_ref: Inventario

# combate
var cooldowns: Array[float] = [1.0, 1.3, 1.7]
var multiplicadores: Array[float] = [1.0, 1.2, 1.5]
var cooldown: float = 0.0


func _ready() -> void:
	add_to_group("player")
	process_mode = Node.PROCESS_MODE_ALWAYS

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

	for alvo in alvos:
		experienciaDropada += randi_range(alvo.experiencia_min, alvo.experiencia_max)

	inventario_ref = get_tree().get_first_node_in_group("inventario_principal")


func _physics_process(delta: float) -> void:
	# ===== MENU STATUS =====
	if Input.is_action_just_pressed("abrir_status"):
		_toggle_menu_status()

	# trava tudo quando pausado
	if get_tree().paused:
		return

	# movimento
	var direction_x = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction_x * SPEED if direction_x != 0 else move_toward(velocity.x, 0, SPEED)

	var direction_y = Input.get_axis("ui_up", "ui_down")
	velocity.y = direction_y * SPEED if direction_y != 0 else move_toward(velocity.y, 0, SPEED)

	# ataque
	for alvo in alvos:
		if Input.is_action_just_pressed("ui_attack") and cooldown <= 0:
			if alvo and alvo.inRange:
				cooldown = mecanicas.atacar(alvo, cooldowns, forca, multiplicadores)
				alvo.cooldownDaCura = 15

				if alvo.vitalidade <= 0:
					_acumular_drops_do_inimigo(alvo)
					alvos.erase(alvo)
					sala.move_child(alvo, 0)
				return

	if cooldown > 0:
		cooldown -= delta

	# cura
	if Input.is_action_pressed("ui_healing") and cooldownDaCura <= 0 and vidaInicial > vitalidade:
		mecanicas.cura(self, 10 * 60 / max(inteligencia / 20, 1))
	elif cooldownDaCura > 0:
		cooldownDaCura -= delta
		barraCura.value = cooldownDaCura

	# fim da sala
	if len(alvos) <= 0 and not dropsRecebido:
		experiencia += experienciaDropada
		moedas += randi_range(5, 15)
		label_moeda.text = str(moedas)
		_entregar_drops_pendentes()
		dropsRecebido = true

	# level up
	if experiencia >= experienciaNecessaria:
		mecanicas.subirNivel(self)
		label_nivel.text = "Lv. " + str(nivel)

	barraExperiencia.value = experiencia
	move_and_slide()


func _toggle_menu_status():
	if menu_status == null:
		return

	if menu_status.visible:
		menu_status.hide()
		get_tree().paused = false
	else:
		menu_status.show()
		menu_status.configurar(self)
		get_tree().paused = true


# ===== DROPS =====
func _acumular_drops_do_inimigo(alvo: inimigo) -> void:
	for item in alvo.coletar_drops():
		_adicionar_drop_pendente(
			item.get("nome", ""),
			item.get("raridade", 0),
			item.get("quantidade", 1)
		)

func _adicionar_drop_pendente(nome, raridade, quantidade):
	for item in drops_pendentes:
		if item["nome"] == nome and item["raridade"] == raridade:
			item["quantidade"] += quantidade
			return

	drops_pendentes.append({
		"nome": nome,
		"raridade": raridade,
		"quantidade": quantidade
	})

func _entregar_drops_pendentes():
	if inventario_ref == null:
		return

	for item in drops_pendentes:
		inventario_ref.adicionar_item(item["nome"], item["raridade"], item["quantidade"])

	drops_pendentes.clear()
