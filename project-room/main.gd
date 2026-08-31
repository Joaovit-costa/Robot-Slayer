extends Node2D

@onready var menu_inventario: Control = get_node_or_null("CanvasLayer/InventoryMenu") as Control
@onready var menu_loja_cura: Control = get_node_or_null("CanvasLayer/LojaItens") as Control
@onready var menu_loja_arma: Control = get_node_or_null("CanvasLayer/LojaItens2") as Control
@onready var menu_status = get_node_or_null("CanvasLayer/MenuStatus") as Control
@onready var menu_habilidades = get_node_or_null("CanvasLayer/MenuHabilidades") as Control
@onready var fundo_escuro: ColorRect = get_node_or_null("CanvasLayer/MeshInstance2D") as ColorRect
@onready var sala: Node2D = get_node_or_null("sala") as Node2D
@onready var tutorial: ControladorTutorial = get_node_or_null("CanvasLayerTutorial/Tutorial") as ControladorTutorial

const ACAO_INVENTARIO := &"ui_inventario"
const ACAO_STATUS := &"ui_status"
const ACAO_HABILIDADE := &"ui_habilidadeMenu"
const ACAO_LOJA := &"ui_interagir"

const TIPO_LOJA_CURA := &"cura"
const TIPO_LOJA_ARMA := &"arma"

var avanco_antes := false
var antes_avancar := 21
var tecla_inventario_estava_pressionada := false
var tecla_loja_estava_pressionada := false
var tecla_status_estava_pressionada := false
var tecla_habilidade_estava_pressionada := false
var menu_pause_instance: CanvasLayer = null
var titulo_item_antes_tutorial := ""
var quantidade_equipamentos_antes_tutorial := 0

var habilidade1_desbloqueada := false
var habilidade2_desbloqueada := false
var habilidade3_desbloqueada := false
var habilidade4_desbloqueada := false
var habilidade5_desbloqueada := false
var habilidade6_desbloqueada := false

func _ready() -> void:
	add_to_group("Main")
	var player = get_tree().get_first_node_in_group("player")
	SaveManager.aplicar_habilidades_desbloqueadas()
	
	_fechar_menus()
	_aplicar_estado_telas()
	menu_inventario.z_index = 2000
	menu_loja_cura.z_index = 2000
	menu_loja_arma.z_index = 2000
	menu_status.z_index = 2000
	menu_habilidades.z_index = 2000
	fundo_escuro.z_index = 1999
	if tutorial != null:
		tutorial.process_mode = Node.PROCESS_MODE_ALWAYS
		tutorial.menu_compras.visible = false
		SaveManager.aplicar_no_tutorial(tutorial)


func _process(_delta: float) -> void:
	if _pause_esta_aberto():
		return

	if _inventario_foi_acionado():
		_alternar_menu(menu_inventario)
	elif _loja_foi_acionada():
		_alternar_loja_disponivel()
	elif menu_status != null and _status_foi_acionado():
		_alternar_menu(menu_status)
	elif menu_habilidades != null and _habilidade_foi_acionado():
		_alternar_menu(menu_habilidades)
	
	desbloquear_habilidade()
	
	if sala != null and sala.color_rect != null and not sala.color_rect.visible:
		_processar_tutorial()
	_atualizar_exibicao_tutorial()
	_aplicar_estado_telas()

func desbloquear_habilidade():
	var player = get_tree().get_first_node_in_group("player")
	
	if tutorial.tutorial >= 60 and not habilidade1_desbloqueada:
		habilidade1_desbloqueada = true
		SaveManager.solicitar_salvamento()
	if sala.salas_passadas - 3 > 5 and not habilidade2_desbloqueada:
		habilidade2_desbloqueada = true
		SaveManager.solicitar_salvamento()
	if player.dano_recebido_sem_morrer >= 200 and not habilidade3_desbloqueada:
		habilidade3_desbloqueada = true
		SaveManager.solicitar_salvamento()
	if player.inimigos_derrotados_usando_missil_reto >= 30 and not habilidade4_desbloqueada:
		habilidade4_desbloqueada = true
		SaveManager.solicitar_salvamento()
	if player.derrotados_utilizando_dash >= 35 and not habilidade5_desbloqueada:
		habilidade5_desbloqueada = true
		SaveManager.solicitar_salvamento()
	if player.salas_dificeis_sem_cura >= 3 and not habilidade6_desbloqueada:
		habilidade6_desbloqueada = true
		SaveManager.solicitar_salvamento()

func _processar_tutorial() -> void:
	if tutorial == null or not tutorial.tutorial_esta_ativo():
		return

	var etapa := tutorial.tutorial

	var houve_clique := Input.is_action_just_pressed("ui_attack")
	var usou_cura := Input.is_action_just_pressed("ui_healing")

	var mudou_direcao := (
		Input.is_action_pressed("ui_left")
		or Input.is_action_pressed("ui_right")
		or Input.is_action_pressed("ui_up")
		or Input.is_action_pressed("ui_down")
	)

	# =========================================================
	# MOVIMENTAÇÃO
	# =========================================================

	if etapa == tutorial.ETAPA_MOVIMENTACAO and mudou_direcao:
		tutorial.avancar()


	# =========================================================
	# ATAQUE
	# =========================================================

	elif etapa == tutorial.ETAPA_ATAQUE and houve_clique:
		tutorial.avancar()


	# =========================================================
	# ABRIR INVENTÁRIO
	# =========================================================

	elif etapa == tutorial.ETAPA_ABRIR_INVENTARIO \
	and menu_inventario.visible \
	and sala.sala_atual.sem_inimigos_na_lista_de_alvos:

		tutorial.avancar_para(tutorial.ETAPA_INVENTARIO_PRIMEIRA)

		titulo_item_antes_tutorial = _obter_titulo_item_selecionado()
		quantidade_equipamentos_antes_tutorial = _quantidade_itens_equipados()


	# =========================================================
	# TUTORIAL DO INVENTÁRIO
	# =========================================================

	elif etapa == tutorial.ETAPA_INVENTARIO_PRIMEIRA \
	and menu_inventario.visible \
	and houve_clique:

		tutorial.avancar()

	elif etapa == tutorial.ETAPA_INVENTARIO_PRIMEIRA + 1 \
	and menu_inventario.visible \
	and _titulo_do_item_foi_alterado():

		tutorial.avancar()

	elif etapa > tutorial.ETAPA_INVENTARIO_PRIMEIRA + 1 \
	and etapa < tutorial.ETAPA_INVENTARIO_FECHAR - 1 \
	and menu_inventario.visible \
	and houve_clique:

		tutorial.avancar()

	elif etapa == tutorial.ETAPA_INVENTARIO_FECHAR - 1 \
	and menu_inventario.visible \
	and _quantidade_itens_equipados() > quantidade_equipamentos_antes_tutorial:

		tutorial.avancar()


	# =========================================================
	# FECHAR INVENTÁRIO
	# =========================================================

	elif etapa == tutorial.ETAPA_INVENTARIO_FECHAR \
	and not menu_inventario.visible:

		tutorial.avancar_para(tutorial.ETAPA_ABRIR_STATUS)


	# =========================================================
	# ABRIR STATUS
	# =========================================================

	elif etapa == tutorial.ETAPA_ABRIR_STATUS \
	and menu_status.visible:

		tutorial.avancar_para(tutorial.ETAPA_STATUS_PRIMEIRA)


	# =========================================================
	# TUTORIAL DO STATUS
	# =========================================================

	elif etapa >= tutorial.ETAPA_STATUS_PRIMEIRA \
	and etapa < tutorial.ETAPA_STATUS_FECHAR \
	and menu_status.visible \
	and houve_clique:

		tutorial.avancar()


	# =========================================================
	# FECHAR STATUS
	# =========================================================

	elif etapa == tutorial.ETAPA_STATUS_FECHAR \
	and not menu_status.visible:

		tutorial.avancar_para(tutorial.ETAPA_INTERFACE_VIDA)


	# =========================================================
	# INTERFACE
	# =========================================================

	elif etapa >= tutorial.ETAPA_INTERFACE_VIDA \
	and etapa < tutorial.ETAPA_INTERFACE_ULTIMA - 1 \
	and not menu_inventario.visible \
	and not menu_status.visible \
	and not menu_habilidades.visible \
	and houve_clique:

		tutorial.avancar()


	elif etapa == tutorial.ETAPA_INTERFACE_ULTIMA - 1 \
	and not menu_inventario.visible \
	and not menu_status.visible \
	and not menu_habilidades.visible \
	and houve_clique:

		tutorial.avancar_para(tutorial.ETAPA_CURA)


	# =========================================================
	# CURA
	# =========================================================

	elif etapa == tutorial.ETAPA_CURA \
	and not menu_inventario.visible \
	and not menu_status.visible \
	and not menu_habilidades.visible \
	and (
		usou_cura
		or sala.sala_atual.protagonista_ref.cooldownDaCura >= 1
	):

		# A próxima etapa DEPOIS DA CURA
		# agora é abrir o menu de habilidades.
		tutorial.avancar_para(tutorial.ETAPA_ABRIR_HABILIDADE)


	# =========================================================
	# ABRIR MENU DE HABILIDADES
	# =========================================================

	elif etapa == tutorial.ETAPA_ABRIR_HABILIDADE:

		if menu_habilidades.visible:

			# Se o detalhe já estiver aberto por algum motivo,
			# manda fechar primeiro.
			if menu_habilidades.destalhes_habilidades.visible:
				tutorial.mostrar_etapa(tutorial.ETAPA_HABILIDADE_FECHAR - 1)

			else:
				tutorial.avancar_para(
					tutorial.ETAPA_HABILIDADE_PRIMEIRA
				)


	# =========================================================
	# ETAPA 21
	#
	# Tutorial dentro do menu principal de habilidades.
	# =========================================================

	elif etapa == tutorial.ETAPA_HABILIDADE_PRIMEIRA \
	and menu_habilidades.visible:

		if menu_habilidades.destalhes_habilidades.visible:

			# Detalhe abriu antes da hora.
			tutorial.mostrar_etapa(
				tutorial.ETAPA_HABILIDADE_FECHAR - 1
			)

		elif houve_clique:

			tutorial.avancar()


	# =========================================================
	# ETAPA 22
	#
	# Ainda dentro do menu principal.
	# =========================================================

	elif etapa == tutorial.ETAPA_HABILIDADE_PRIMEIRA + 1 \
	and menu_habilidades.visible:

		if menu_habilidades.destalhes_habilidades.visible:

			# Abriu detalhe antes da etapa 23.
			tutorial.mostrar_etapa(
				tutorial.ETAPA_HABILIDADE_FECHAR - 1
			)

		elif houve_clique:

			tutorial.avancar()


	# =========================================================
	# ETAPA 23
	#
	# O jogador precisa abrir os detalhes das habilidades.
	# =========================================================

	elif etapa == tutorial.ETAPA_HABILIDADE_PRIMEIRA + 2 \
	and menu_habilidades.visible:

		if menu_habilidades.destalhes_habilidades.visible:

			# Abriu corretamente.
			tutorial.avancar()


	# =========================================================
	# ETAPAS 24 E 25
	#
	# Essas etapas obrigatoriamente acontecem dentro
	# dos detalhes das habilidades.
	# =========================================================

	elif etapa > tutorial.ETAPA_HABILIDADE_PRIMEIRA + 2 \
	and etapa < tutorial.ETAPA_HABILIDADE_FECHAR - 1:

		if not menu_habilidades.visible:

			# Saiu completamente do menu.
			# Volta para a etapa 23.
			tutorial.avancar_para(
				tutorial.ETAPA_HABILIDADE_PRIMEIRA + 2
			)

		elif not menu_habilidades.destalhes_habilidades.visible:

			# Fechou os detalhes antes de terminar.
			# Volta para a etapa 23.
			tutorial.avancar_para(
				tutorial.ETAPA_HABILIDADE_PRIMEIRA + 2
			)

		elif houve_clique:

			tutorial.avancar()


	# =========================================================
	# ETAPA 26
	#
	# Última etapa dentro dos detalhes.
	# O próximo passo é fechar os detalhes.
	# =========================================================

	elif etapa == tutorial.ETAPA_HABILIDADE_FECHAR - 1:

		if not menu_habilidades.visible:

			# Se fechou o menu inteiro, precisa voltar
			# para abrir novamente.
			tutorial.avancar_para(
				tutorial.ETAPA_HABILIDADE_PRIMEIRA + 2
			)

		elif not menu_habilidades.destalhes_habilidades.visible:

			# Detalhes foram fechados.
			tutorial.avancar()


	# =========================================================
	# ETAPA 27
	#
	# Agora o jogador precisa fechar o MENU PRINCIPAL
	# de habilidades.
	# =========================================================

	elif etapa == tutorial.ETAPA_HABILIDADE_FECHAR:

		if not menu_habilidades.visible:

			# Menu principal fechado.
			# Volta para a última etapa da interface.
			tutorial.avancar_para(
				tutorial.ETAPA_INTERFACE_ULTIMA
			)


	# =========================================================
	# ÚLTIMA ETAPA DA INTERFACE
	#
	# Depois de terminar habilidades, mostra novamente
	# a última etapa da interface.
	# =========================================================

	elif etapa == tutorial.ETAPA_INTERFACE_ULTIMA \
	and not menu_inventario.visible \
	and not menu_status.visible \
	and not menu_habilidades.visible:

		if houve_clique:

			tutorial.avancar_para(
				tutorial.ETAPA_CONCLUIDA
			)


func _atualizar_exibicao_tutorial() -> void:
	if sala.color_rect.visible:
		return

	if tutorial == null or sala == null or not tutorial.tutorial_esta_ativo():
		if tutorial != null:
			tutorial.ocultar_etapas()
		return

	if sala.salas_passadas == 0:
		if tutorial.tutorial == tutorial.ETAPA_MOVIMENTACAO:
			tutorial.mostrar_etapa_atual()
		else:
			tutorial.ocultar_etapas()
		return

	if sala.salas_passadas != 1:
		tutorial.ocultar_etapas()
		return

	if tutorial.tutorial == tutorial.ETAPA_ABRIR_INVENTARIO:
		if sala.sala_atual != null and sala.sala_atual.porta_liberada:
			tutorial.mostrar_etapa_atual()
		else:
			tutorial.ocultar_etapas()
		return

	if tutorial.tutorial >= tutorial.ETAPA_INVENTARIO_PRIMEIRA \
	and tutorial.tutorial <= tutorial.ETAPA_INVENTARIO_FECHAR:

		if menu_inventario != null and menu_inventario.visible:
			tutorial.mostrar_etapa_atual()
		else:
			tutorial.mostrar_etapa(tutorial.ETAPA_ABRIR_INVENTARIO)

		return

	if tutorial.tutorial >= tutorial.ETAPA_STATUS_PRIMEIRA \
	and tutorial.tutorial <= tutorial.ETAPA_STATUS_FECHAR:

		if menu_status != null and menu_status.visible:
			tutorial.mostrar_etapa_atual()
		else:
			tutorial.mostrar_etapa(tutorial.ETAPA_ABRIR_STATUS)

		return

	if tutorial.tutorial >= tutorial.ETAPA_ABRIR_HABILIDADE \
	and tutorial.tutorial <= tutorial.ETAPA_HABILIDADE_FECHAR:

		if menu_habilidades != null and menu_habilidades.visible:
			tutorial.mostrar_etapa_atual()
		else:
			tutorial.mostrar_etapa(tutorial.ETAPA_ABRIR_HABILIDADE)

		return

	tutorial.mostrar_etapa_atual()


func _obter_titulo_item_selecionado() -> String:
	if menu_inventario == null or not menu_inventario.has_method("obter_titulo_item_selecionado"):
		return ""
	return str(menu_inventario.obter_titulo_item_selecionado())


func _titulo_do_item_foi_alterado() -> bool:
	var titulo_atual := _obter_titulo_item_selecionado()
	return not titulo_atual.is_empty() and titulo_atual != titulo_item_antes_tutorial


func _quantidade_itens_equipados() -> int:
	if menu_inventario == null or not menu_inventario.has_method("quantidade_itens_equipados"):
		return 0
	return int(menu_inventario.quantidade_itens_equipados())

func _pause_esta_aberto() -> bool:
	return menu_pause_instance != null


func _alternar_menu(menu: Control) -> void:
	if menu == null:
		return

	var deve_abrir := not menu.visible
	_fechar_menus()
	menu.visible = deve_abrir


func _fechar_menus() -> void:
	if menu_inventario != null:
		menu_inventario.visible = false
	if menu_loja_cura != null:
		menu_loja_cura.visible = false
	if menu_loja_arma != null:
		menu_loja_arma.visible = false
	if menu_status != null:
		menu_status.visible = false
	if menu_habilidades != null:
		menu_habilidades.visible = false


func _aplicar_estado_telas() -> void:
	var inventario_aberto := menu_inventario != null and menu_inventario.visible
	var loja_cura_aberta := menu_loja_cura != null and menu_loja_cura.visible
	var loja_arma_aberta := menu_loja_arma != null and menu_loja_arma.visible
	var status_aberto: bool = menu_status != null and menu_status.visible
	var habilidades_aberto: bool = menu_habilidades != null and menu_habilidades.visible
	var pause_aberto := _pause_esta_aberto()

	var menu_aberto := (
		inventario_aberto
		or loja_cura_aberta
		or loja_arma_aberta
		or status_aberto
		or pause_aberto
		or habilidades_aberto
	)

	if menu_aberto:
		SoundManager.parar_passo()

	var tutorial_visivel := tutorial != null and tutorial.tem_etapa_visivel()
	if sala != null:
		sala.process_mode = Node.PROCESS_MODE_DISABLED if menu_aberto or tutorial_visivel else Node.PROCESS_MODE_INHERIT

	if fundo_escuro != null:
		fundo_escuro.visible = menu_aberto and not pause_aberto

	if menu_inventario != null:
		menu_inventario.process_mode = Node.PROCESS_MODE_INHERIT
	if menu_loja_cura != null:
		menu_loja_cura.process_mode = Node.PROCESS_MODE_INHERIT
	if menu_loja_arma != null:
		menu_loja_arma.process_mode = Node.PROCESS_MODE_INHERIT
	if menu_status != null:
		menu_status.process_mode = Node.PROCESS_MODE_INHERIT
	if menu_habilidades != null:
		menu_habilidades.process_mode = Node.PROCESS_MODE_INHERIT

func _obter_tipo_loja_disponivel() -> StringName:
	if sala == null:
		return &""

	if not sala.has_method("obter_loja_disponivel"):
		return &""

	return sala.obter_loja_disponivel()


func _inventario_foi_acionado() -> bool:
	if InputMap.has_action(ACAO_INVENTARIO):
		return Input.is_action_just_pressed(ACAO_INVENTARIO)

	var pressionada_agora := Input.is_physical_key_pressed(KEY_E)
	var acabou_de_pressionar := pressionada_agora and not tecla_inventario_estava_pressionada
	tecla_inventario_estava_pressionada = pressionada_agora
	return acabou_de_pressionar


func _loja_foi_acionada() -> bool:
	if InputMap.has_action(ACAO_LOJA):
		return Input.is_action_just_pressed(ACAO_LOJA)

	var pressionada_agora := Input.is_physical_key_pressed(KEY_F)
	var acabou_de_pressionar := pressionada_agora and not tecla_loja_estava_pressionada
	tecla_loja_estava_pressionada = pressionada_agora
	return acabou_de_pressionar


func _status_foi_acionado() -> bool:
	if InputMap.has_action(ACAO_STATUS):
		return Input.is_action_just_pressed(ACAO_STATUS)

	var pressionada_agora := Input.is_physical_key_pressed(KEY_TAB)
	var acabou_de_pressionar := pressionada_agora and not tecla_status_estava_pressionada
	tecla_status_estava_pressionada = pressionada_agora
	return acabou_de_pressionar

func _habilidade_foi_acionado() -> bool:
	if InputMap.has_action(ACAO_HABILIDADE):
		return Input.is_action_just_pressed(ACAO_HABILIDADE)

	var pressionada_agora := Input.is_physical_key_pressed(KEY_R)
	var acabou_de_pressionar := pressionada_agora and not tecla_habilidade_estava_pressionada
	tecla_habilidade_estava_pressionada = pressionada_agora
	return acabou_de_pressionar

func _alternar_loja_disponivel() -> void:
	if menu_loja_cura != null and menu_loja_cura.visible:
		menu_loja_cura.visible = false
		_aplicar_estado_telas()
		return

	if menu_loja_arma != null and menu_loja_arma.visible:
		menu_loja_arma.visible = false
		_aplicar_estado_telas()
		return

	var tipo_loja := _obter_tipo_loja_disponivel()

	if tipo_loja == TIPO_LOJA_CURA:
		_alternar_menu(menu_loja_cura)
	elif tipo_loja == TIPO_LOJA_ARMA:
		_alternar_menu(menu_loja_arma)	
