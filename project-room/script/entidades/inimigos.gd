extends CharacterBody2D

@export var vitalidade: int = 0
@export var defesa: int = 0
@export var forca: int = 0
@export var velocidade: int = 0
@export var inteligencia: int = 0
@export var temperamento: String = ""
@export var cooldowns := [0.0, 0.0, 0.0]
@export var multiplicadores := [1.0, 1.0, 1.0]
@export var protagonista_ref: protagonista

var cooldown: float = 0.0
var ataque : int

func _ready() -> void:
	pass

func atacar(_delta: float, tipoAtaque) -> void:
	if protagonista_ref == null or protagonista_ref.vitalidade <= 0:
		return
	randomize()
	tipoAtaque = cooldowns[randi() % cooldowns.size()]
	cooldown += tipoAtaque
	
	protagonista_ref.vitalidade -= max(forca * multiplicadores[cooldowns.find(tipoAtaque)] - protagonista_ref.defesa, 1)
	protagonista_ref.vitalidade = max(protagonista_ref.vitalidade, 0)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_attack") and cooldown <= 0:
		atacar(_delta, ataque)
		
	elif cooldown > 0:
		cooldown -= 1.0 * _delta
