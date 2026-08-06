extends inimigo

# ============ ATAQUE A DISTANCIA ============
@export_group("ataque a distancia")
@export var projetil_scene: PackedScene
@export var velocidade_projetil: float = 340.0
@export var alcance_projetil: float = 520.0
@export var distancia_minima_tiro: float = 90.0
@export_group("")
# ============================================


func _physics_process(delta: float) -> void:
	if spawn_ativo:
		return
	# ============ SEM ALVO ============
	if protagonista_ref == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	# ================================

	# ======== ACOES AO MORRER ========
	if vitalidade <= 0:
		_processar_morte()
		return
	# =================================

	# ============ DISTANCIA ============
	distancia = global_position.distance_to(protagonista_ref.global_position)
	# ==================================

	var direcao: Vector2 = global_position.direction_to(protagonista_ref.global_position)
	direcao.x = mecanicas.ajustar_eixo(direcao.x)
	direcao.y = mecanicas.ajustar_eixo(direcao.y)

	# ============ MOVIMENTO DO ATIRADOR ============

	# Se estiver longe demais, aproxima
	if distancia > distancia_ataque:
		velocity = direcao * velocidade
		direcao_animacao = direcao

	# Se estiver perto demais, recua
	elif distancia < distancia_minima_tiro:
		velocity = -direcao * velocidade
		direcao_animacao = -direcao

	# Se estiver na distância ideal, para e atira
	else:
		direcao_animacao = direcao
		velocity.x = move_toward(velocity.x, 0.0, velocidade)
		velocity.y = move_toward(velocity.y, 0.0, velocidade)

		if cooldown <= 0.0:
			_tocar_animacao(_animacao_por_direcao("atacar"))
			atirar()
	# ===============================================

	# ============ COOLDOWN ============
	if cooldown > 0.0:
		cooldown -= delta
	# ==================================

	# ============ CURAR ==============
	if vitalidade < vidaInicial and not tomouDano:
		tomouDano = true
		cooldownDaCura += 15
	elif vitalidade == vidaInicial:
		tomouDano = false

	if tomouDano and cooldownDaCura <= 0 and vitalidade < vidaInicial:
		mecanicas.cura(self, 7)
		if vitalidade > vidaInicial:
			vitalidade = vidaInicial
	elif cooldownDaCura > 0:
		cooldownDaCura -= delta
	# =================================

	# ============ ANIMACAO ============
	_atualizar_animacao()
	# ==================================

	move_and_slide()


func atirar() -> void:
	if projetil_scene == null:
		push_warning("Projetil Scene nao configurada no inimigo atirador.")
		cooldown = 1.0
		return

	if cooldowns.is_empty():
		return
	cooldown = maxf(0.0, cooldowns.pick_random()) * multiplicador_cooldown_ataque

	var projetil = projetil_scene.instantiate()
	get_parent().add_child(projetil)

	projetil.global_position = global_position

	var direcao: Vector2 = global_position.direction_to(protagonista_ref.global_position)

	if projetil.has_method("configurar"):
		projetil.configurar(direcao, velocidade_projetil, alcance_projetil, forca)
