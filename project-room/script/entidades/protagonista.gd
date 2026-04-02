extends CharacterBody2D
class_name protagonista

@export var alvo: inimigo
@onready var alcance := Area2D

var vitalidade: int = 100
var defesa: int = 0
var forca: int = 10
var velocidade: int = 0
var inteligencia: int = 0

var cooldowns := [1.0, 1.3, 1.7]
var multiplicadores := [1.0, 1.2, 1.5]
var cooldown: float = 0.0

const SPEED = 300.0

const Mecanicas = preload("res://script/Mecanicas.gd")
var mecanicas = Mecanicas.new()

func _ready() -> void:
	randomize()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	print("ok")

func _physics_process(delta: float) -> void:
	var directionx := Input.get_axis("ui_left", "ui_right")
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	var directiony := Input.get_axis("ui_up", "ui_down")
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	if Input.is_action_just_pressed("ui_attack") and cooldown <= 0.0:
		if alvo != null:
			cooldown = mecanicas.atacar(alvo, cooldowns, forca, multiplicadores)

	elif cooldown > 0.0:
		cooldown -= delta

	if alvo != null:
		pass
	else:
		print("Sem alvo definido", " ", cooldown)

	move_and_slide()
