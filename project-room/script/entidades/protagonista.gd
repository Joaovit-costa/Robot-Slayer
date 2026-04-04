extends CharacterBody2D
class_name protagonista

# ============ REFERÊNCIAS ============
@export var alvos : Array[inimigo]
@onready var alcance: Area2D = $Area2D
@onready var barraVida: ProgressBar = $CanvasLayer/ProgressBar
@onready var sala: Node2D = $".."

const Mecanicas = preload("res://script/Mecanicas.gd")
var mecanicas = Mecanicas.new()
# =====================================


# ============ ATRIBUTOS ============
var vitalidade: int = 6
var vidaInicial: int
var defesa: int = 2
var forca: int = 5
var inteligencia: int = 4

const SPEED: float = 220

# Sistema de cura
var cooldownDaCura: float = 0.0
# ===================================


# ============ ATAQUE ============
var cooldowns: Array[float] = [1.0, 1.3, 1.7]
var multiplicadores: Array[float] = [1.0, 1.2, 1.5]
var cooldown: float = 0.0
# =================================


func _ready() -> void:
	# ============ INICIALIZAÇÃO ============
	randomize()
	vitalidade *= 5
	vidaInicial = vitalidade
	defesa *= 3
	# ======================================
	
	
	# ============ BARRA DE VIDA ==============
	barraVida.max_value = vitalidade
	barraVida.value = vitalidade
	# =========================================


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
	

	# ============ ATAQUE ============
	for alvo in alvos:
		if Input.is_action_just_pressed("ui_attack") and cooldown <= 0.0:
			if alvo != null and alvo.inRange:
				cooldown = mecanicas.atacar(alvo, cooldowns, forca, multiplicadores)
				alvo.cooldownDaCura = 15
				if alvo.vitalidade == 0:
					alvos.erase(alvo)
					sala.move_child(alvo, 0)
				return

	# ============ COOLDOWN ============
	if cooldown > 0.0:
		cooldown -= delta
	# =================================
	# =================================
	
	# ============ CURAR ==============
	if Input.is_action_pressed("ui_healing") and cooldownDaCura <= 0 and vidaInicial > vitalidade:
		mecanicas.cura(self, 10 * 60 / int(max(inteligencia / 20, 1)))
		if vitalidade > vidaInicial:
			vitalidade = vidaInicial
	elif cooldownDaCura > 0:
		cooldownDaCura = max(cooldownDaCura - delta, 0)
	# =================================


	# ============ MOVIMENTO FINAL ============
	move_and_slide()
	# ========================================
