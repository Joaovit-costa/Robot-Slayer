extends Area2D

var direcao: Vector2 = Vector2.ZERO
var velocidade: float = 300.0
var alcance: float = 500.0
var distancia_percorrida: float = 0.0
var dano: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func configurar(nova_direcao: Vector2, nova_velocidade: float, novo_alcance: float, forca_inimigo: int) -> void:
	direcao = nova_direcao.normalized()
	velocidade = nova_velocidade
	alcance = novo_alcance
	dano = forca_inimigo
	
	rotation = direcao.angle()


func _physics_process(delta: float) -> void:
	var movimento: Vector2 = direcao * velocidade * delta
	
	global_position += movimento
	distancia_percorrida += movimento.length()
	
	if distancia_percorrida >= alcance:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is protagonista:
		body.receber_dano(dano)
		queue_free()
