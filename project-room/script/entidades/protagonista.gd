extends CharacterBody2D
class_name protagonista

# ============ REFERENCIAS ============
@export var alvos: Array[inimigo]
@export var cena_missil: PackedScene
@export var cena_missil_teleguiado: PackedScene
@onready var hud: Hud = get_tree().get_first_node_in_group("hud") as Hud

@onready var alcance: Area2D = $Sprite2D/Area2D
@onready var hitbox_ataque: CollisionShape2D = $Sprite2D/Area2D/CollisionShape2D
@onready var sala: Node2D = $"../.."

var barraVida: ProgressBar
var barraCura: ProgressBar
var barraExperiencia: ProgressBar
var label_nivel: Label
var label_moeda: Label
var curando := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var escudo: Node2D = $Escudo
@onready var vida_escudo: ProgressBar = $Escudo/ProgressBar
@onready var area_dash_ofensivo: CollisionShape2D = $Area2D/CollisionShape2D


@onready var Mecanicas = load("res://script/data/Mecanicas.gd")
@onready var mecanicas = Mecanicas.new()
# =====================================

var morto: bool = false
var tela_morte_visivel: bool = false
var atributos_inicializados: bool = false


# ============ ATRIBUTOS ============
var vitalidade: int = 6
var vidaInicial: int
var vidaAtual: int = 0
var defesa: int = 2
var forca: int = 5
var inteligencia: int = 4
var pontosExperiencia: int = 0
var experiencia: int = 0
var nivel: int = 1
var moedas: int = 0
var pontosStatus: int = 0
var status = ["vitalidade", "defesa", "forca", "inteligencia"]
var dano_missil : int

var SPEED: float = 200
const COOLDOWN_CURA_BASE: float = 25.0
const COOLDOWN_CURA_MINIMO: float = 10.0
const TEMPO_INVULNERABILIDADE_APOS_DANO: float = 0.35

var ultima_direcao: String = "down"
var direcao_animacao: Vector2 = Vector2.DOWN
var direcao_ataque: Vector2 = Vector2.DOWN
var posicao_alcance_original: Vector2 = Vector2.ZERO

var experienciaNecessaria = int(nivel * 1.2 + 40)

var inimigos_derrotados_usando_missil_reto := 0
var dano_recebido_sem_morrer := 0
var derrotados_utilizando_dash := 0
var salas_dificeis_sem_cura := 0

var ataque_com := "false"
var dash_ativo := false
var furia_ativa := false
var curou_na_sala := false
var escudo_ativo := false

# Sistema de cura
var cooldownDaCura: float = 0.0
var invulnerabilidade_restante: float = 0.0

# Sistema de ataque
var atacando: bool = false
var tempo_ataque_restante: float = 0.0
var indice_ataque_atual: int = 0
var inimigos_acertados_no_ataque: Array[inimigo] = []

# sistema de drop
var experienciaDropada: int = 0
var dropsRecebido: bool = false
var drops_pendentes: Array[Dictionary] = []
var possui_inimigos_na_sala: bool = false
var multiplicador_moedas_sala: float = 1.0

# inventario
var inventario_ref: Inventario
# ===================================


# ============ MUSICA ============
var musica_normal = preload("res://res/sons/Musica_Ambiente_1.mp3")
var musica_low_hp = preload("res://res/sons/Música_um_coração.mp3")


var em_perigo: bool = false
# =================================


# ============ SFX ============
var som_ataque = preload("res://res/sons/Som_Ataque.mp3")
var som_andar = preload("res://res/sons/Som andando.mp3")
# =================================

# ============ ATAQUE ============
var cooldowns: Array[float] = [1.0, 1.3, 1.7]
var multiplicadores: Array[float] = [1.0, 1.2, 1.5]
var cooldown: float = 0.0
const DURACAO_ANIMACAO_ATAQUE: float = 0.9
const ALCANCE_GOLPE: float = 80.0
# =================================

@onready var habilidades := [$"../../../CanvasLayer/MenuHabilidades/Panel/HBoxContainer/Control/SlotEquipados",
						$"../../../CanvasLayer/MenuHabilidades/Panel/HBoxContainer/Control/SlotEquipados2",
						$"../../../CanvasLayer/MenuHabilidades/Panel/HBoxContainer/Control/SlotEquipados3"]


func _ready() -> void:
	add_to_group("player")
	hud = get_tree().get_first_node_in_group("hud") as Hud
	var _main := get_tree().get_first_node_in_group("Main")

	if hud == null:
		return

	barraVida = hud.barraVida
	barraCura = hud.barra_de_cura
	barraExperiencia = hud.barra_de_experiencia
	label_nivel = hud.label_nivel
	label_moeda = hud.label_moeda
	
	preparar_atributos_para_sala()
	# A preparacao pode ter ocorrido antes de o HUD entrar na arvore; sincroniza
	# novamente agora que as barras visuais existem.
	sincronizar_vida()
	cooldownDaCura = minf(cooldownDaCura, calcular_cooldown_cura())
	
	barraExperiencia.max_value = experienciaNecessaria
	barraExperiencia.value = experiencia

	label_nivel.text = "Lv. " + str(nivel)
	label_moeda.text = str(moedas)

	barraCura.max_value = calcular_cooldown_cura()
	barraCura.value = cooldownDaCura
	
	recalcular_experiencia_dropada()
	possui_inimigos_na_sala = not alvos.is_empty()

	inventario_ref = get_tree().get_first_node_in_group(
		"inventario_principal"
	) as Inventario

	# ============ ANIMACAO ============
	animation_tree.active = true
	posicao_alcance_original = alcance.position
	# A hitbox permanece na fisica para que get_overlapping_bodies() tenha
	# tempo de registrar os corpos. O dano continua protegido por `atacando`.
	alcance.monitoring = true
	hitbox_ataque.disabled = false
	# ==================================

	# 🎧 MUSICA INICIAL
	SoundManager.tocar_musica(musica_normal)
	
	call_deferred("_sincronizar_menu_status")
	
	add_to_group("protagonista")

func _physics_process(delta: float) -> void:
	if morto:
		return
	invulnerabilidade_restante = maxf(0.0, invulnerabilidade_restante - delta)
	# As faixas da AnimationPlayer tambem alteram `disabled`. Forcar a forma
	# ativa evita que a lista de sobreposicoes fique vazia entre os frames.
	if hitbox_ataque.disabled:
		hitbox_ataque.set_deferred("disabled", false)
		
	# ============ MOVIMENTO ============
	var direcao = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	if direcao != Vector2.ZERO:
		direcao = direcao.normalized()

	velocity = direcao * SPEED
	# ===================================
	# ============ DIRECAO ANIMACAO ============
	if velocity.length() > 0:
		direcao_animacao = velocity.normalized()
	# ==========================================
	
# ============ ATAQUE ============
	if Input.is_action_just_pressed("ui_attack") and cooldown <= 0.0 and not atacando:
		iniciar_ataque()
		
		
	if atacando:
		tempo_ataque_restante -= delta
		executar_ataque()
		
		if tempo_ataque_restante <= 0.0:	
			finalizar_ataque()
	# =================================
	
	
	# ============ COOLDOWN ============
	if cooldown > 0.0:
		cooldown -= delta
	# =================================

	# ============ CURAR ==============
	if (
		Input.is_action_pressed("ui_healing")
		and cooldownDaCura <= 0
		and vidaInicial > vidaAtual
	):

		mecanicas.cura(
			self,
			calcular_cooldown_cura()
		)

		barraCura.max_value = cooldownDaCura

		if vidaAtual > vidaInicial:
			vidaAtual = vidaInicial
			_atualizar_barra_vida()

		_solicitar_salvamento()

	elif cooldownDaCura > 0:

		cooldownDaCura -= delta
		barraCura.value = cooldownDaCura
	# =================================
	
	# ===== AO MATAR TODOS DA SALA =====
	if possui_inimigos_na_sala and alvos.is_empty() and not dropsRecebido:

		experiencia += experienciaDropada

		var moedasDropadas := int(round(randi_range(5, 15) * multiplicador_moedas_sala))
		moedas += moedasDropadas

		label_moeda.text = str(moedas)

		_entregar_drops_pendentes()

		dropsRecebido = true
		_solicitar_salvamento()
	# ==================================


	# ========= SUBIR DE NIVEL =========
	var subiu_de_nivel : bool = false
	while experiencia >= experienciaNecessaria and experienciaNecessaria > 0:

		mecanicas.subirNivel(self)
		subiu_de_nivel = true
	
	if subiu_de_nivel:
		label_nivel.text = str("Lv. ", nivel)
		_sincronizar_menu_status()
		_solicitar_salvamento()
	barraExperiencia.value = experiencia
	# ==================================


	# ============ ANIMACAO ============
	if curando:
		move_and_slide()
	elif atacando:
		animation_state.travel("Attack")

	elif velocity.length() > 5:
		animation_state.travel("Walk")

	else:
		animation_state.travel("Idle")

	animation_tree.set(
		"parameters/Idle/blend_position",
		direcao_animacao
	)

	animation_tree.set(
		"parameters/Walk/blend_position",
		direcao_animacao
	)

	animation_tree.set(
		"parameters/Attack/blend_position",
		direcao_ataque if atacando else direcao_animacao
	)
	# ==================================

	if (Input.is_action_pressed("habilidade1") and habilidades[0].tempo_restante <= 0):
		verificar_habilidade_equipada(0)
	if (Input.is_action_pressed("habilidade2") and habilidades[1].tempo_restante <= 0):
		verificar_habilidade_equipada(1)
	if (Input.is_action_pressed("habilidade3") and habilidades[2].tempo_restante <= 0):
		verificar_habilidade_equipada(2)
	
	if furia_ativa or escudo_ativo:
		for hab in habilidades:
			if hab.Nome == "Fúria" and furia_ativa:
				hab.tempo_restante = hab.cooldown
			if hab.Nome == "Campo de Força" and escudo_ativo:
				hab.tempo_restante = hab.cooldown
				if vida_escudo.value <= 0:
					escudo_ativo = false
					escudo.visible = false

	# ============ MOVIMENTO FINAL ============
	move_and_slide()
	# ========================================


	
	# ============ SOM DE PASSO ============
	if velocity.length() > 5 and not atacando:
		SoundManager.iniciar_passo(som_andar)
	else:
		SoundManager.parar_passo()
	# ======================================

	atualizar_hierarquia()
	# 🎧 VERIFICAR VIDA (MUSICA)
	verificar_vida()
	
	if vidaAtual <= 0 and not morto:
		_processar_morte()

func atualizar_hierarquia():
	z_index = int(global_position.y / 20)

	for inimigo in alvos:
		inimigo.z_index = int(inimigo.global_position.y / 20)

func verificar_habilidade_equipada(tecla):
	var _gerenciador_habilidades = get_tree().get_first_node_in_group("gerenciador_habilidades")
	if habilidades[tecla].Nome == "Investida":
		_gerenciador_habilidades.usar_habilidade(habilidades[tecla])
		Investida()
	elif habilidades[tecla].Nome == "Míssil de Precisão":
		_gerenciador_habilidades.usar_habilidade(habilidades[tecla])
		disparar_missil_reto(self)
	elif habilidades[tecla].Nome == "Campo de Força":
		_gerenciador_habilidades.usar_habilidade(habilidades[tecla])
		campo_forca()
	elif habilidades[tecla].Nome == "Míssil Teleguiado":
		_gerenciador_habilidades.usar_habilidade(habilidades[tecla])
		disparar_missil_teleguiado(self)
	elif habilidades[tecla].Nome == "Investida Ofensiva":
		_gerenciador_habilidades.usar_habilidade(habilidades[tecla])
		investida_ofenciva()
	elif habilidades[tecla].Nome == "Fúria":
		_gerenciador_habilidades.usar_habilidade(habilidades[tecla])
		furia()

func Investida():
	SPEED *= 7
	dash_ativo = true
	await get_tree().create_timer(0.08).timeout
	dash_ativo = false
	SPEED /= 7

func investida_ofenciva():
	SPEED *= 6
	dash_ativo = true
	area_dash_ofensivo.set_deferred("disabled", false)
	await get_tree().create_timer(0.12).timeout
	area_dash_ofensivo.set_deferred("disabled", true)
	dash_ativo = false
	SPEED /= 6

func _on_area_dash_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigos"):
		body.receber_dano(forca * 0.6)
		if body.vitalidade <= 0:
				_acumular_drops_do_inimigo(body)
				alvos.erase(body)
				var sala_do_alvo := body.get_parent()
				if sala_do_alvo != null:
					sala_do_alvo.move_child(body, 1)

func disparar_missil_reto(player: protagonista) -> void:
	var missil := cena_missil.instantiate() as Missil

	get_tree().current_scene.add_child(missil)

	missil.global_position = global_position

	var mouse_pos := get_global_mouse_position()
	dano_missil = int((forca * 80 / 100) + (inteligencia * 20 / 100))
	if furia_ativa:
		dano_missil *= 1.6
	var direcao := global_position.direction_to(mouse_pos)

	missil.configurar(direcao, dano_missil, player)

func disparar_missil_teleguiado(player: protagonista) -> void:
	var missil_teleguiado := cena_missil_teleguiado.instantiate() as MissilTeleguiado

	get_tree().current_scene.add_child(missil_teleguiado)

	missil_teleguiado.global_position = global_position

	var mouse_pos := get_global_mouse_position()
	dano_missil = int((forca * 35 / 100) + (inteligencia * 10 / 100))
	if furia_ativa:
		dano_missil *= 1.6
	var direcao := global_position.direction_to(mouse_pos)

	missil_teleguiado.configurar(direcao, dano_missil, player)

func furia():
	furia_ativa = true
	SPEED *= 1.4
	
	await get_tree().create_timer(15.0).timeout
	
	furia_ativa = false
	SPEED /= 1.4

func campo_forca():
	escudo_ativo = true
	escudo.visible = true
	vida_escudo.max_value = vidaInicial * 0.8
	vida_escudo.value = vidaInicial * 0.8



func _sincronizar_menu_status() -> void:
	var menus_status := get_tree().get_nodes_in_group("menu_status")

	for menu in menus_status:
		if menu.has_method("configurar"):
			menu.configurar(self)
		elif menu.has_method("atualizar_menu_status"):
			menu.atualizar_menu_status()
			
			
func verificar_vida():

	var vida_percent = float(vidaAtual) / float(max(vidaInicial, 1))

	if vida_percent <= 0.2 and not em_perigo:

		em_perigo = true
		SoundManager.tocar_musica(musica_low_hp)

	elif vida_percent > 0.2 and em_perigo:

		em_perigo = false
		SoundManager.tocar_musica(musica_normal)


func calcular_vida_maxima() -> int:
	return max(vitalidade * 5, 1)


func calcular_cooldown_cura() -> float:
	# O countdown usa delta em segundos. A formula anterior retornava 600 s
	# para inteligencia baixa, tornando cura praticamente inutil em combate.
	return maxf(
		COOLDOWN_CURA_MINIMO,
		COOLDOWN_CURA_BASE - (float(inteligencia) * 0.25)
	)


func preparar_atributos_para_sala() -> void:
	if atributos_inicializados:
		return

	vidaInicial = calcular_vida_maxima()
	vidaAtual = vidaInicial
	defesa *= 3
	SaveManager.aplicar_no_player(self)
	sincronizar_vida()
	atributos_inicializados = true


func sincronizar_vida() -> void:
	vidaInicial = max(vidaInicial, calcular_vida_maxima())
	vidaAtual = clamp(vidaAtual, 0, vidaInicial)
	_atualizar_barra_vida()


func receber_dano(dano: int) -> void:
	var dano_final :float= max(dano, 0)
	if dano_final <= 0 or invulnerabilidade_restante > 0.0:
		return

	invulnerabilidade_restante = TEMPO_INVULNERABILIDADE_APOS_DANO
	if not escudo_ativo:
		vidaAtual = max(vidaAtual - dano_final, 0)
	else:
		vida_escudo.value = max(vida_escudo.value - dano_final, 0)
	_atualizar_barra_vida()
	_solicitar_salvamento()


func receber_cura(cura: int) -> void:
	vidaAtual = min(vidaAtual + max(cura, 0), vidaInicial)
	curando = true
	animation_state.travel("cura")
	await get_tree().create_timer(1.0).timeout
	curando = false

	_atualizar_barra_vida()
	_solicitar_salvamento()
	


func aumentar_atributo(nome: String) -> bool:
	if pontosStatus <= 0:
		return false

	match nome:
		"forca":
			forca += 1
		"defesa":
			defesa += 1
		"vitalidade":
			vitalidade += 1
			vidaInicial = calcular_vida_maxima()
			vidaAtual = min(vidaAtual + 5, vidaInicial)
			_atualizar_barra_vida()
		"inteligencia":
			inteligencia += 1
			if barraCura != null:
				barraCura.max_value = calcular_cooldown_cura()
				barraCura.value = minf(cooldownDaCura, barraCura.max_value)
		_:
			return false

	pontosStatus -= 1
	_solicitar_salvamento()
	return true


func tem_moedas(valor: int) -> bool:
	return moedas >= max(valor, 0)


func gastar_moedas(valor: int) -> bool:
	var custo :int= max(valor, 0)
	if moedas < custo:
		return false

	moedas -= custo
	label_moeda.text = str(moedas)
	_solicitar_salvamento()
	return true


func _atualizar_barra_vida() -> void:
	if barraVida == null:
		return
	barraVida.max_value = vidaInicial
	barraVida.value = vidaAtual


func _solicitar_salvamento() -> void:
	if SaveManager.aplicando_save:
		return
	SaveManager.solicitar_salvamento()


func recalcular_experiencia_dropada() -> void:
	experienciaDropada = 0
	var alvos_validos: Array[inimigo] = []
	for alvo in alvos:
		if alvo == null or not is_instance_valid(alvo):
			continue
		alvos_validos.append(alvo)

		experienciaDropada += randi_range(
			alvo.experiencia_min,
			alvo.experiencia_max
		)
	alvos = alvos_validos


func configurar_recompensas_sala(novo_multiplicador_moedas: float) -> void:
	multiplicador_moedas_sala = maxf(1.0, novo_multiplicador_moedas)


func _acumular_drops_do_inimigo(alvo: inimigo) -> void:
	if alvo == null:
		return

	for item in alvo.coletar_drops():

		_adicionar_drop_pendente(
			str(item.get("nome", "")),
			int(item.get("raridade", ItensData.Raridade.COMUM)),
			int(item.get("quantidade", 1))
		)


func _adicionar_drop_pendente(
	nome: String,
	raridade: int,
	quantidade: int
) -> void:

	for item in drops_pendentes:

		if (
			str(item.get("nome", "")) == nome
			and int(item.get("raridade", ItensData.Raridade.COMUM)) == raridade
		):

			item["quantidade"] = int(item.get("quantidade", 0)) + quantidade
			return

	drops_pendentes.append({
		"nome": nome,
		"raridade": raridade,
		"quantidade": quantidade
	})


func _entregar_drops_pendentes() -> void:

	if inventario_ref == null:
		inventario_ref = get_tree().get_first_node_in_group(
			"inventario_principal"
		) as Inventario

	if inventario_ref == null:
		return

	for item in drops_pendentes:

		inventario_ref.adicionar_item(
			str(item.get("nome", "")),
			int(item.get("raridade", ItensData.Raridade.COMUM)),
			int(item.get("quantidade", 1))
		)

	drops_pendentes.clear()


func iniciar_ataque() -> void:
	if cooldowns.is_empty() or cooldowns.size() != multiplicadores.size():
		push_error("Configuracao de ataque invalida no protagonista.")
		return

	atacando = true
	direcao_ataque = direcao_animacao
	_congelar_alcance_do_ataque()
	tempo_ataque_restante = DURACAO_ANIMACAO_ATAQUE
	indice_ataque_atual = randi() % cooldowns.size()
	cooldown = cooldowns[indice_ataque_atual]
	inimigos_acertados_no_ataque.clear()

	# 🎧 SOM DE ATAQUE
	SoundManager.tocar_sfx(som_ataque, 8)


func executar_ataque() -> void:
	# A Area2D e ativada pela animacao apenas para a parte visual. A consulta
	# direta usa a mesma forma e nao perde o golpe quando essa ativacao chega
	# adiada ao processamento fisico.
	for body in alcance.get_overlapping_bodies():
		_aplicar_dano_da_hitbox(body)

	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = hitbox_ataque.shape
	consulta.transform = hitbox_ataque.global_transform
	consulta.collision_mask = alcance.collision_mask
	consulta.collide_with_areas = false
	consulta.collide_with_bodies = true
	consulta.exclude = [get_rid()]

	for resultado in get_world_2d().direct_space_state.intersect_shape(consulta):
		_aplicar_dano_da_hitbox(resultado.get("collider") as Node)

	# O combate usa o grupo de inimigos. A lista `alvos` continua exclusiva
	# para controlar a progressao e as recompensas da sala.
	var direcao_golpe := direcao_ataque.normalized()
	for no_inimigo in get_tree().get_nodes_in_group(&"inimigos"):
		var alvo := no_inimigo as inimigo
		if alvo == null or not is_instance_valid(alvo):
			continue

		var vetor_ate_alvo := global_position.direction_to(alvo.global_position)
		if (
			global_position.distance_to(alvo.global_position) <= ALCANCE_GOLPE
			and vetor_ate_alvo.dot(direcao_golpe) > 0.2
		):
			_aplicar_dano_da_hitbox(alvo)


func finalizar_ataque() -> void:
	atacando = false
	tempo_ataque_restante = 0.0
	inimigos_acertados_no_ataque.clear()
	_restaurar_alcance_do_ataque()


func _congelar_alcance_do_ataque() -> void:
	# Mantem a hitbox do golpe no ponto em que o ataque comecou.
	# Assim o jogador pode andar sem arrastar a area ativa do ataque.
	var posicao_alcance_global := alcance.global_position
	alcance.set_as_top_level(true)
	alcance.global_position = posicao_alcance_global


func _restaurar_alcance_do_ataque() -> void:
	# Depois do ataque, a hitbox volta a acompanhar o Sprite2D normalmente.
	alcance.set_as_top_level(false)
	alcance.position = posicao_alcance_original
	
	
func _aplicar_dano_da_hitbox(body: Node) -> void:
	if not atacando:
		return

	var alvo := body as inimigo
	if alvo == null or alvo.vitalidade <= 0:
		return

	if alvo in inimigos_acertados_no_ataque:
		return

	inimigos_acertados_no_ataque.append(alvo)

	var dano: float = max(
		forca * multiplicadores[indice_ataque_atual] - alvo.defesa,
		1
	)
	
	if furia_ativa:
		dano *= 2
	
	# A animacao de dano deve apontar o inimigo para quem o atingiu.
	var direcao_dano: Vector2 = alvo.global_position.direction_to(global_position)
	alvo.receber_dano(dano, direcao_dano)

	if alvo.vitalidade <= 0:
		_acumular_drops_do_inimigo(alvo)
		alvos.erase(alvo)
		var sala_do_alvo := alvo.get_parent()
		if sala_do_alvo != null:
			sala_do_alvo.move_child(alvo, 1)


func _on_area_2d_body_entered(body: Node) -> void:
	_aplicar_dano_da_hitbox(body)

func _processar_morte() -> void:
	morto = true
	dano_recebido_sem_morrer = 0

	# Impede o jogador de continuar se movimentando
	velocity = Vector2.ZERO

	# Para o ataque, caso esteja atacando
	atacando = false
	tempo_ataque_restante = 0.0
	inimigos_acertados_no_ataque.clear()

	# Para o som de passos
	SoundManager.parar_passo()

	# Reduz os atributos
	var diminuidos: Array = [
		status.pick_random(),
		status.pick_random(),
		status.pick_random()
	]

	for diminuido in diminuidos:
		if diminuido == "vitalidade" and vitalidade > 3:
			vitalidade -= 3

		elif diminuido == "defesa" and defesa > 3:
			defesa -= 3

		elif diminuido == "forca" and forca > 3:
			forca -= 3

		elif diminuido == "inteligencia" and inteligencia > 3:
			inteligencia -= 3

	if nivel > 3:
		nivel -= 3

	_solicitar_salvamento()

	# Toca a animação de morte
	animation_state.travel("morte")
	
	await get_tree().create_timer(1.5).timeout

	# Depois da animação, mostra a tela de morte
	_exibir_tela_morte()


func _exibir_tela_morte() -> void:
	var tela_morte = get_tree().get_first_node_in_group("tela_morte")

	if tela_morte == null:
		push_error("Tela de morte não encontrada!")
		return

	tela_morte.exibir()

func restaurar_vida() -> void:
	vidaInicial = calcular_vida_maxima()
	vidaAtual = vidaInicial

	_atualizar_barra_vida()
	_solicitar_salvamento()
