extends CharacterBody2D
class_name protagonista

@export var alvo: inimigo
@onready var alcance: Area2D = $Area2D

var vitalidade: int = 100
var defesa: int = 0
var forca: int = 10
var velocidade: int = 0
var inteligencia: int = 0

var cooldowns: Array[float] = [1.0, 1.3, 1.7]
var multiplicadores: Array[float] = [1.0, 1.2, 1.5]
var cooldown: float = 0.0
var inimigo_no_range: bool = false

const SPEED: float = 300.0

const Mecanicas = preload("res://script/Mecanicas.gd")
var mecanicas = Mecanicas.new()

func _ready() -> void:
	randomize()
	alcance.body_entered.connect(_on_area_body_entered)
	alcance.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body: Node) -> void:
	if body is inimigo:
		alvo = body
		inimigo_no_range = true

func _on_area_body_exited(body: Node) -> void:
	if body == alvo:
		alvo = null
		inimigo_no_range = false

func _physics_process(delta: float) -> void:
	var direction_x: float = Input.get_axis("ui_left", "ui_right")
	if direction_x != 0.0:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	var direction_y: float = Input.get_axis("ui_up", "ui_down")
	if direction_y != 0.0:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0.0, SPEED)

	if Input.is_action_just_pressed("ui_attack") and cooldown <= 0.0:
		if alvo != null and inimigo_no_range:
			cooldown = mecanicas.atacar(alvo, cooldowns, forca, multiplicadores)
			print("atacado")

	if cooldown > 0.0:
		cooldown -= delta

	move_and_slide()
