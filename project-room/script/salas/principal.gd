class_name Salas
extends Node2D

@export var salas_tutorial: Array[Node2D] = []
@export var salas: Array[Node2D] = []
@export var sala_inicial: Node2D
@export var duracao_fade: float = 1.0

@export_group("Balanceamento")
@export var crescimento_status_por_sala: float = 0.24
@export var crescimento_xp_por_sala: float = 0.2
@export var crescimento_velocidade_por_sala: float = 0.0
@export var limite_multiplicador_status: float = 10.0
@export var limite_multiplicador_xp: float = 8.0
@export var limite_multiplicador_velocidade: float = 1.6
@export var limite_multiplicador_moedas: float = 4.0
# Soma dos atributos iniciais reais do protagonista: 6 vitalidade + 6 defesa
# (a defesa base e multiplicada por 3) + 5 forca + 4 inteligencia.
@export var status_inicial_player_referencia: int = 21
@export_group("")

@onready var modelos_salas: Node2D = get_node_or_null("Salas") as Node2D
@onready var color_rect: ColorRect = get_node_or_null("ColorRect") as ColorRect
@onready var sala_02: Sala = $Salas/Sala02
@onready var sala_geral: Node2D= $".."
@onready var tutorial: ControladorTutorial = get_node_or_null("../CanvasLayerTutorial/Tutorial") as ControladorTutorial
@onready var label_salas:= $ColorRect2/Label
@onready var tala_morte: CanvasLayer = $TalaMorte
@onready var color_rect_2: ColorRect = $ColorRect2
@onready var hud: Hud = $Hud

const POSICAO_MODELOS_DESATIVADOS := Vector2(1000000, 1000000)
const TIPO_LOJA_NENHUMA := &""
const TIPO_LOJA_CURA := &"cura"
const TIPO_LOJA_ARMA := &"arma"

var sala_atual: Node2D
var transicao_em_andamento: bool = false
var loja_disponivel: StringName = TIPO_LOJA_NENHUMA
@onready var salas_passadas: int = 0
var sala_atual_id: String = ""


func _ready() -> void:
	add_to_group("gerenciador_salas")
	SaveManager.aplicar_no_gerenciador_salas(self)
	label_salas.text = "sala " + str(salas_passadas)
	color_rect_2.z_index = 1980
	_configurar_color_rect()
	_desativar_modelos_de_sala()
	_iniciar_primeira_sala()


func solicitar_transicao_de_sala(
	_sala_origem: Node2D,
	cena_ao_entrar_na_porta: String = ""
) -> void:

	if transicao_em_andamento:
		return

	# Salva ANTES de criar o próximo player.
	SaveManager.salvar_estado_atual()

	transicao_em_andamento = true
	_bloquear_inputs_da_transicao()

	await _fazer_fade(1.0)

	salas_passadas += 1

	_criar_sala_por_progresso(cena_ao_entrar_na_porta)

	label_salas.text = "sala " + str(salas_passadas)

	await _fazer_fade(0.0)

	_liberar_inputs_da_transicao()
	transicao_em_andamento = false

func _input(_event: InputEvent) -> void:
	if transicao_em_andamento:
		get_viewport().set_input_as_handled()


func _iniciar_primeira_sala() -> void:
	var modelo := _obter_sala_por_id(sala_atual_id)

	if modelo == null:
		modelo = _obter_sala_tutorial_por_progresso()

	if modelo == null:
		modelo = sala_inicial

	if modelo == null and not salas.is_empty():
		modelo = salas[0]

	if modelo == null:
		return

	_criar_sala_por_modelo(modelo)


func _criar_sala_por_progresso(cena_ao_entrar_na_porta: String = "") -> void:
	var sala_tutorial := _obter_sala_tutorial_por_progresso()
	if sala_tutorial != null:
		_criar_sala_por_modelo(sala_tutorial)
		return

	if cena_ao_entrar_na_porta.is_empty() or _cena_ao_entrar_eh_tutorial(cena_ao_entrar_na_porta):
		_criar_sala_aleatoria()
	else:
		_criar_sala_por_cena(cena_ao_entrar_na_porta)


func _obter_sala_tutorial_por_progresso() -> Node2D:
	if salas_passadas < 0 or salas_passadas >= salas_tutorial.size():
		return null

	var modelo := salas_tutorial[salas_passadas]
	if modelo == null or not is_instance_valid(modelo):
		return null

	return modelo


func _obter_sala_por_id(sala_id: String) -> Node2D:
	if sala_id.is_empty():
		return null

	if sala_inicial != null and str(sala_inicial.name) == sala_id:
		return sala_inicial

	for sala_modelo in salas_tutorial:
		if sala_modelo != null and is_instance_valid(sala_modelo) and str(sala_modelo.name) == sala_id:
			return sala_modelo

	for sala_modelo in salas:
		if sala_modelo != null and is_instance_valid(sala_modelo) and str(sala_modelo.name) == sala_id:
			return sala_modelo

	return null


func _cena_ao_entrar_eh_tutorial(cena_path: String) -> bool:
	if cena_path.is_empty():
		return false

	var path_normalizado := cena_path.replace("\\", "/").to_lower()
	return path_normalizado.contains("/tutorial/")


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

	sala_atual_id = str(nova_sala.name)
	_balancear_sala(nova_sala)
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

	sala_atual_id = str(modelo.name)
	_balancear_sala(nova_sala)
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
	_configurar_area_loja_da_sala_atual()


func _remover_sala_atual() -> void:
	loja_disponivel = TIPO_LOJA_NENHUMA

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


func obter_loja_disponivel() -> StringName:
	return loja_disponivel


func _configurar_area_loja_da_sala_atual() -> void:
	loja_disponivel = TIPO_LOJA_NENHUMA

	if sala_atual == null:
		return

	var tipo_loja := _obter_tipo_loja_da_sala(sala_atual.name)
	if tipo_loja == TIPO_LOJA_NENHUMA:
		return

	var area_loja := sala_atual.get_node_or_null("Area2D") as Area2D
	if area_loja == null:
		return

	area_loja.body_entered.connect(_on_area_loja_body_entered.bind(tipo_loja))
	area_loja.body_exited.connect(_on_area_loja_body_exited.bind(tipo_loja))


func _obter_tipo_loja_da_sala(nome_sala: StringName) -> StringName:
	match str(nome_sala):
		"Sala13":
			return TIPO_LOJA_CURA
		"Sala14":
			return TIPO_LOJA_ARMA
		_:
			return TIPO_LOJA_NENHUMA


func _on_area_loja_body_entered(body: Node, tipo_loja: StringName) -> void:
	if body is protagonista and tutorial != null:
		tutorial.menu_compras.visible = true
		loja_disponivel = tipo_loja


func _on_area_loja_body_exited(body: Node, tipo_loja: StringName) -> void:
	if body is protagonista and loja_disponivel == tipo_loja and tutorial != null:
		tutorial.menu_compras.visible = false
		loja_disponivel = TIPO_LOJA_NENHUMA


func _balancear_sala(nova_sala: Node2D) -> void:
	if nova_sala == null:
		return

	var player := nova_sala.get_node_or_null("Protagonista") as protagonista
	if player != null and player.has_method("preparar_atributos_para_sala"):
		# Aplica o save antes de medir a referencia: a dificuldade deve refletir
		# os atributos com os quais o jogador realmente entra na sala.
		player.preparar_atributos_para_sala()
	var referencia_player := _calcular_referencia_player(player)
	var fator_player :float= max(0.8, referencia_player / float(max(status_inicial_player_referencia, 1)))
	var multiplicador_status :float= clamp(
		1.0 + (salas_passadas / 2 * crescimento_status_por_sala * fator_player),
		1.0,
		limite_multiplicador_status
	)
	var multiplicador_xp :float= clamp(
		1.0 + (salas_passadas * crescimento_xp_por_sala * fator_player),
		1.0,
		limite_multiplicador_xp
	)
	var multiplicador_velocidade :float= clamp(
		1.0 + (salas_passadas * crescimento_velocidade_por_sala),
		1.0,
		limite_multiplicador_velocidade
	)
	var multiplicador_moedas: float = clamp(
		multiplicador_xp,
		1.0,
		limite_multiplicador_moedas
	)
	var inimigos: Array[inimigo] = []
	for node in nova_sala.find_children("*", "CharacterBody2D", true, false):
		var alvo := node as inimigo
		if alvo != null:
			inimigos.append(alvo)

	# Em salas com muitos inimigos, cada um ataca menos frequentemente. Isso
	# limita o dano agregado sem reduzir a variedade ou a quantidade de inimigos.
	var multiplicador_cooldown_ataque: float = clampf(
		1.0 + (maxi(inimigos.size(), 1) - 1) * 0.75,
		1.0,
		4.0
	)
	var multiplicador_ataque: float = 1.0 + (
		(multiplicador_status - 1.0) * 0.4
	)

	if player != null and player.has_method("configurar_recompensas_sala"):
		player.configurar_recompensas_sala(multiplicador_moedas)

	for alvo in inimigos:
		_balancear_inimigo(
			alvo,
			multiplicador_status,
			multiplicador_xp,
			multiplicador_velocidade,
			multiplicador_ataque,
			multiplicador_cooldown_ataque
		)


func _calcular_referencia_player(player: protagonista) -> int:
	if player == null:
		return status_inicial_player_referencia

	return max(
		player.vitalidade
		+ player.defesa
		+ player.forca
		+ player.inteligencia,
		1
	)


func _balancear_inimigo(
	alvo: inimigo,
	multiplicador_status: float,
	multiplicador_xp: float,
	multiplicador_velocidade: float,
	multiplicador_ataque: float,
	multiplicador_cooldown_ataque: float
) -> void:
	alvo.vitalidade = max(1, int(round(alvo.vitalidade * multiplicador_status)))
	alvo.defesa = max(0, int(round(alvo.defesa * multiplicador_status)))
	alvo.forca = max(1, int(round(alvo.forca * multiplicador_ataque)))
	alvo.inteligencia = max(0, int(round(alvo.inteligencia * multiplicador_status)))
	alvo.velocidade *= multiplicador_velocidade
	alvo.multiplicador_cooldown_ataque = multiplicador_cooldown_ataque
	alvo.experiencia_min = max(1, int(round(alvo.experiencia_min * multiplicador_xp)))
	alvo.experiencia_max = max(
		alvo.experiencia_min,
		int(round(alvo.experiencia_max * multiplicador_xp))
	)
