extends Node2D

@export var salas_tutorial: Array[Node2D] = []
@export var salas: Array[Node2D] = []
@export var sala_inicial: Node2D
@export var duracao_fade: float = 1.0

@onready var modelos_salas: Node2D = get_node_or_null("Salas") as Node2D
@onready var color_rect: ColorRect = get_node_or_null("ColorRect") as ColorRect

const POSICAO_MODELOS_DESATIVADOS := Vector2(1000000, 1000000)

var sala_atual: Node2D
var transicao_em_andamento: bool = false


func _ready() -> void:
	randomize()
	_configurar_color_rect()
	_desativar_modelos_de_sala()
	_iniciar_primeira_sala()


func solicitar_transicao_de_sala(_sala_origem: Node2D, cena_ao_entrar_na_porta: String = "") -> void:
	if transicao_em_andamento:
		return

	transicao_em_andamento = true
	_bloquear_inputs_da_transicao()
	await _fazer_fade(1.0)

	if cena_ao_entrar_na_porta.is_empty():
		_criar_sala_aleatoria()
	else:
		_criar_sala_por_cena(cena_ao_entrar_na_porta)

	await _fazer_fade(0.0)
	_liberar_inputs_da_transicao()
	transicao_em_andamento = false


func _input(_event: InputEvent) -> void:
	if transicao_em_andamento:
		get_viewport().set_input_as_handled()


func _iniciar_primeira_sala() -> void:
	var modelo := sala_inicial

	if modelo == null and not salas_tutorial.is_empty():
		modelo = salas_tutorial[0]
	elif modelo == null and not salas.is_empty():
		modelo = salas[0]

	if modelo == null:
		return

	_criar_sala_por_modelo(modelo)


func _criar_sala_aleatoria() -> void:
	var modelos_disponiveis: Array[Node2D] = []

	for sala in salas:
		if sala != null and is_instance_valid(sala):
			modelos_disponiveis.append(sala)

	if modelos_disponiveis.is_empty():
		return

	var indice := randi_range(0, modelos_disponiveis.size() - 1)
	_criar_sala_por_modelo(modelos_disponiveis[indice])


func _criar_sala_por_cena(cena_path: String) -> void:
	var cena := load(cena_path) as PackedScene
	if cena == null:
		_criar_sala_aleatoria()
		return

	_remover_sala_atual()

	var nova_sala := cena.instantiate() as Node2D
	if nova_sala == null:
		return

	_adicionar_sala_ativa(nova_sala)


func _criar_sala_por_modelo(modelo: Node2D) -> void:
	if modelo == null or not is_instance_valid(modelo):
		return

	_remover_sala_atual()

	var nova_sala := modelo.duplicate(
		DUPLICATE_SIGNALS
		| DUPLICATE_GROUPS
		| DUPLICATE_SCRIPTS
		| DUPLICATE_USE_INSTANTIATION
	) as Node2D

	if nova_sala == null:
		return

	_adicionar_sala_ativa(nova_sala)


func _adicionar_sala_ativa(nova_sala: Node2D) -> void:
	add_child(nova_sala)
	sala_atual = nova_sala
	sala_atual.visible = true
	sala_atual.process_mode = (
		Node.PROCESS_MODE_DISABLED
		if transicao_em_andamento
		else Node.PROCESS_MODE_INHERIT
	)
	move_child(sala_atual, 0)


func _remover_sala_atual() -> void:
	if sala_atual != null and is_instance_valid(sala_atual):
		sala_atual.queue_free()

	sala_atual = null


func _desativar_modelos_de_sala() -> void:
	if modelos_salas == null:
		return

	modelos_salas.visible = false
	modelos_salas.process_mode = Node.PROCESS_MODE_DISABLED
	modelos_salas.position = POSICAO_MODELOS_DESATIVADOS

	for sala_modelo in modelos_salas.get_children():
		if sala_modelo is Node2D:
			sala_modelo.visible = false
			sala_modelo.process_mode = Node.PROCESS_MODE_DISABLED


func _configurar_color_rect() -> void:
	if color_rect == null:
		return

	color_rect.visible = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.modulate.a = 0.0
	color_rect.position = Vector2.ZERO
	color_rect.size = get_viewport_rect().size
	color_rect.z_index = 1000


func _fazer_fade(alpha_final: float) -> void:
	if color_rect == null:
		return

	color_rect.size = get_viewport_rect().size
	color_rect.visible = true

	var tween := create_tween()
	tween.tween_property(
		color_rect,
		"modulate:a",
		alpha_final,
		duracao_fade
	)

	await tween.finished

	if alpha_final <= 0.0:
		color_rect.visible = false


func _bloquear_inputs_da_transicao() -> void:
	SoundManager.parar_passo()

	if sala_atual != null and is_instance_valid(sala_atual):
		sala_atual.process_mode = Node.PROCESS_MODE_DISABLED

	for action in InputMap.get_actions():
		Input.action_release(action)


func _liberar_inputs_da_transicao() -> void:
	if sala_atual != null and is_instance_valid(sala_atual):
		sala_atual.process_mode = Node.PROCESS_MODE_INHERIT
