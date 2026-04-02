extends CharacterBody2D
class_name inimigo

@export var vitalidade: int = 100
@export var defesa: int = 0
@export var forca: int = 5
@export var velocidade: int = 0
@export var inteligencia: int = 0
@export var temperamento: String = ""
@export var cooldowns := [0.8, 1.2, 1.6]
@export var multiplicadores := [1.0, 1.3, 1.6]

@export var protagonista_ref: protagonista
@onready var alcance: Area2D = $Area2D

var cooldown: float = 0.0
var player_em_range: bool = false

const Mecanicas = preload("res://script/Mecanicas.gd")
var mecanicas = Mecanicas.new()

func _ready() -> void:
	randomize()
	alcance.body_entered.connect(_on_area_body_entered)
	alcance.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body: Node) -> void:
	if body is protagonista:
		protagonista_ref = body
		player_em_range = true

func _on_area_body_exited(body: Node) -> void:
	if body == protagonista_ref:
		protagonista_ref = null
		player_em_range = false

func _physics_process(delta: float) -> void:
	
	if protagonista_ref != null and cooldown <= 0.0 and player_em_range:
		cooldown = mecanicas.atacar(protagonista_ref, cooldowns, forca, multiplicadores)

	elif cooldown > 0.0:
		cooldown -= delta
