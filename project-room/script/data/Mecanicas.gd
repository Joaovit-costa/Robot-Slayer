extends RefCounted

func atacar(atacado, cooldowns: Array[float], forca: int, multiplicadores: Array[float]) -> float:
	if atacado == null or cooldowns.is_empty() or cooldowns.size() != multiplicadores.size():
		return 0.0

	if atacado.has_method("receber_dano"):
		if int(atacado.get("vidaAtual")) <= 0:
			return 0.0
	elif int(atacado.get("vitalidade")) <= 0:
		return 0.0

	var indice_ataque := randi() % cooldowns.size()
	var cooldown_gerado: float = cooldowns[indice_ataque]
	var dano := float(forca) * multiplicadores[indice_ataque]

	if atacado.has_method("receber_dano"):
		atacado.receber_dano(int(dano))
	else:
		atacado.vitalidade = max(atacado.vitalidade - dano, 0)
		atacado.barraVida.value = atacado.vitalidade
	
	if atacado is protagonista:
		atacado.dano_recebido_sem_morrer += forca
	
	return cooldown_gerado


func ajustar_eixo(valor: float) -> float:
	if valor > 0:
		if valor <= 0.5:
			return 0.5
		return 1.0
	elif valor < 0:
		if valor >= -0.5:
			return -0.5
		return -1.0
	return 0.0


func cura(curado, tempo_para_cura: float) -> void:
	if curado == null:
		return

	var inteligencia_efetiva := int(curado.get("inteligencia"))
	if curado.has_method("obter_inteligencia_efetiva"):
		inteligencia_efetiva = int(curado.obter_inteligencia_efetiva())

	var vida_maxima := maxi(int(curado.get("vidaInicial")), 1)
	var quantidade_cura: int
	if curado is protagonista:
		quantidade_cura = mini(
			int(round(vida_maxima * 0.40)),
			maxi(1, int(round(vida_maxima * 0.12 + inteligencia_efetiva * 1.2)))
		)
	else:
		quantidade_cura = mini(
			int(round(vida_maxima * 0.20)),
			maxi(1, inteligencia_efetiva)
		)
	if curado.has_method("receber_cura"):
		curado.receber_cura(quantidade_cura)
	else:
		curado.set("vitalidade", max(0, int(curado.get("vitalidade")) + quantidade_cura))
		var barra_vida := curado.get("barraVida") as ProgressBar
		if barra_vida != null:
			barra_vida.value = int(curado.get("vitalidade"))
	curado.set("cooldownDaCura", max(0.0, tempo_para_cura))
	
	if curado is protagonista:
		curado.salas_dificeis_sem_cura = 0
		curado.curou_na_sala = true


func subirNivel(player) -> void:
	if player == null:
		return
		
	player.nivel += 1
	player.experiencia -= player.experienciaNecessaria
	player.experienciaNecessaria = Balanceamento.experiencia_para_proximo_nivel(
		player.nivel
	)
	player.barraExperiencia.max_value = player.experienciaNecessaria
	player.pontosExperiencia += Balanceamento.PONTOS_STATUS_POR_NIVEL
	player.pontosStatus += Balanceamento.PONTOS_STATUS_POR_NIVEL
