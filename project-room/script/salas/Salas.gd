extends Node2D
class_name Sala

@export var protagonista_path: NodePath = ^"Protagonista"
@export var portas: Array[AnimatedSprite2D] = []
@export var range_porta_path: NodePath = ^"Range Porta"
@export_file("*.tscn") var cena_ao_entrar_na_porta: String

var protagonista_ref: protagonista
var tem_inimigo_na_lista_de_alvos: bool = false
var sem_inimigos_na_lista_de_alvos: bool = true
var inimigos_na_lista_de_alvos: Array[inimigo] = []
var porta_liberada: bool = false

@onready var dificuldade: Label = $StaticBody2D/ColorRect2/Label

func _ready() -> void:
	protagonista_ref = get_node_or_null(protagonista_path) as protagonista
	_configurar_range_porta(false)
	atualizar_informacao_dos_alvos()


func _physics_process(_delta: float) -> void:
	atualizar_informacao_dos_alvos()
	if sem_inimigos_na_lista_de_alvos and not porta_liberada:
		_liberar_porta()
	


func atualizar_informacao_dos_alvos() -> void:
	inimigos_na_lista_de_alvos.clear()

	if protagonista_ref == null or not is_instance_valid(protagonista_ref):
		protagonista_ref = get_node_or_null(protagonista_path) as protagonista

	if protagonista_ref == null:
		# Sem referencia ao jogador nao ha como afirmar que a sala foi limpa.
		# Manter a porta fechada evita liberar progresso por erro de configuracao.
		tem_inimigo_na_lista_de_alvos = true
		sem_inimigos_na_lista_de_alvos = false
		return

	for alvo in protagonista_ref.alvos:
		if alvo != null and is_instance_valid(alvo):
			inimigos_na_lista_de_alvos.append(alvo)

	tem_inimigo_na_lista_de_alvos = not inimigos_na_lista_de_alvos.is_empty()
	sem_inimigos_na_lista_de_alvos = not tem_inimigo_na_lista_de_alvos


func _liberar_porta() -> void:
	porta_liberada = true
	_configurar_range_porta(true)

	for porta in portas:
		if porta != null and is_instance_valid(porta):
			porta.play()

	portas.clear()


func _configurar_range_porta(ativar_colisoes: bool) -> void:
	var range_porta := get_node_or_null(range_porta_path)
	if range_porta == null:
		return

	for collision in range_porta.find_children("*", "CollisionShape2D", true, false):
		collision.disabled = not ativar_colisoes

	for collision in range_porta.find_children("*", "CollisionPolygon2D", true, false):
		collision.disabled = not ativar_colisoes

	for area in range_porta.find_children("*", "Area2D", true, false):
		if not area.body_entered.is_connected(_on_range_porta_body_entered):
			area.body_entered.connect(_on_range_porta_body_entered)


func _on_range_porta_body_entered(body: Node) -> void:
	if not porta_liberada:
		return

	var player := body as protagonista
	if player == null:
		return
	
	var gerenciador_salas := _buscar_gerenciador_salas()
	
	if dificuldade.text == "Difícil" and not player.curou_na_sala:
		player.salas_dificeis_sem_cura += 1

	player.curou_na_sala = false
	SaveManager.solicitar_salvamento()
	
	if gerenciador_salas != null:
		gerenciador_salas.solicitar_transicao_de_sala(
			self,
			cena_ao_entrar_na_porta
		)

		return

	if not cena_ao_entrar_na_porta.is_empty():
		get_tree().change_scene_to_file(cena_ao_entrar_na_porta)


func _buscar_gerenciador_salas() -> Node:
	var node_atual := get_parent()

	while node_atual != null:
		if node_atual.has_method("solicitar_transicao_de_sala"):
			return node_atual

		node_atual = node_atual.get_parent()

	return null
