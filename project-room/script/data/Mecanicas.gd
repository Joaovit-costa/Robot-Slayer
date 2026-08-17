extends RefCounted

const PONTOS_STATUS_POR_NIVEL: int = 3

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
	var dano : float= max(forca * multiplicadores[indice_ataque] - atacado.defesa, 1)

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

	var quantidade_cura: int = max(0, int(int(curado.get("inteligencia")) * 1.5))
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
	player.experienciaNecessaria = int(player.nivel * 1.2 + 40)
	player.barraExperiencia.max_value = player.experienciaNecessaria
	player.pontosExperiencia += PONTOS_STATUS_POR_NIVEL
	player.pontosStatus += PONTOS_STATUS_POR_NIVEL
