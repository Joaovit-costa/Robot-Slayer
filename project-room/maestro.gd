extends Node

@onready var node_2d: Node2D = $Node2D
@onready var menu_inicial: Control = $MenuInicial
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var hud: Hud = $Node2D/sala/Hud
@onready var color_rect: ColorRect = $ColorRect

var em_transicao: bool = false


func _ready() -> void:
	get_tree().paused = false
	
	# =========================
	# JOGO
	# =========================
	node_2d.visible = false
	node_2d.process_mode = Node.PROCESS_MODE_DISABLED
	
	# =========================
	# HUD
	# =========================
	hud.visible = false
	
	# =========================
	# MENU INICIAL
	# =========================
	menu_inicial.visible = true
	menu_inicial.process_mode = Node.PROCESS_MODE_INHERIT
	
	# =========================
	# PAUSE
	# =========================
	pause_menu.visible = false
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# =========================
	# FADE
	# =========================
	color_rect.visible = true
	color_rect.modulate.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if not node_2d.visible:
		return

	# Não permite interações durante uma transição
	if em_transicao:
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			_fechar_pause()
		else:
			_abrir_pause()


# =========================================================
# PAUSE
# =========================================================

func _abrir_pause() -> void:
	if em_transicao:
		return
	
	pause_menu.visible = true
	get_tree().paused = true


func _fechar_pause() -> void:
	if em_transicao:
		return
	
	pause_menu.visible = false
	get_tree().paused = false


# =========================================================
# MENU INICIAL
# =========================================================

func _on_entrar_pressed() -> void:
	if em_transicao:
		return
	
	await _transicao_para_jogo()


func _on_sair_pressed() -> void:
	if em_transicao:
		return
	
	await _transicao_para_sair()


# =========================================================
# BOTÕES DO PAUSE
# =========================================================

func _on_botao_continuar_pressed() -> void:
	if em_transicao:
		return
	
	_fechar_pause()


func _on_botao_sair_pressed() -> void:
	if em_transicao:
		return
	
	await _transicao_para_menu()


# =========================================================
# TRANSIÇÃO: MENU → JOGO
# =========================================================

func _transicao_para_jogo() -> void:
	em_transicao = true
	
	# Garante que o jogo esteja despausado
	get_tree().paused = false
	
	# Bloqueia interação com a tela
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# -------------------------
	# Fade para preto
	# -------------------------
	var tween := create_tween()
	
	tween.tween_property(
		color_rect,
		"modulate:a",
		1.0,
		0.5
	)
	
	await tween.finished
	
	# -------------------------
	# Troca para o jogo
	# -------------------------
	menu_inicial.visible = false
	
	node_2d.visible = true
	node_2d.process_mode = Node.PROCESS_MODE_INHERIT
	
	hud.visible = true
	
	# Dá um frame para o Godot atualizar a tela
	await get_tree().process_frame
	
	# -------------------------
	# Fade de volta
	# -------------------------
	tween = create_tween()
	
	tween.tween_property(
		color_rect,
		"modulate:a",
		0.0,
		0.5
	)
	
	await tween.finished
	
	# Libera interação
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	em_transicao = false


# =========================================================
# TRANSIÇÃO: PAUSE → MENU INICIAL
# =========================================================

func _transicao_para_menu() -> void:
	em_transicao = true
	
	# Remove o pause antes da transição
	get_tree().paused = false
	
	# Bloqueia interação
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# -------------------------
	# Fade para preto
	# -------------------------
	var tween := create_tween()
	
	tween.tween_property(
		color_rect,
		"modulate:a",
		1.0,
		0.5
	)
	
	await tween.finished
	
	# -------------------------
	# Troca para o menu
	# -------------------------
	node_2d.visible = false
	node_2d.process_mode = Node.PROCESS_MODE_DISABLED
	
	hud.visible = false
	
	pause_menu.visible = false
	
	menu_inicial.visible = true
	menu_inicial.process_mode = Node.PROCESS_MODE_INHERIT
	
	await get_tree().process_frame
	
	# -------------------------
	# Fade de volta
	# -------------------------
	tween = create_tween()
	
	tween.tween_property(
		color_rect,
		"modulate:a",
		0.0,
		0.5
	)
	
	await tween.finished
	
	# Libera interação
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	em_transicao = false


# =========================================================
# TRANSIÇÃO: MENU INICIAL → FECHAR JOGO
# =========================================================

func _transicao_para_sair() -> void:
	em_transicao = true
	
	# Garante que o jogo não esteja pausado
	get_tree().paused = false
	
	# Bloqueia interação
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# -------------------------
	# Fade para preto
	# -------------------------
	var tween := create_tween()
	
	tween.tween_property(
		color_rect,
		"modulate:a",
		1.0,
		0.8
	)
	
	await tween.finished
	
	# -------------------------
	# Tela totalmente preta
	# Fecha o jogo
	# -------------------------
	get_tree().quit()
