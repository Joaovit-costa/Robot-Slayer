extends Node

const PONTOS_STATUS_POR_NIVEL: int = 3

func atacar(atacado, cooldowns: Array, forca: int, multiplicadores: Array) -> float:
	if atacado == null:
		return 0.0

	if atacado.has_method("receber_dano"):
		if atacado.vidaAtual <= 0:
			return 0.0
	elif atacado.vitalidade <= 0:
		return 0.0

	var indice_ataque := randi() % cooldowns.size()
	var cooldown_gerado: float = cooldowns[indice_ataque]
	var dano : float= max(forca * multiplicadores[indice_ataque] - atacado.defesa, 1)

	if atacado.has_method("receber_dano"):
		atacado.receber_dano(int(dano))
	else:
		atacado.vitalidade = max(atacado.vitalidade - dano, 0)
		atacado.barraVida.value = atacado.vitalidade

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


func cura(curado, tempoParaCura):
	if curado.has_method("receber_cura"):
		curado.receber_cura(int(curado.inteligencia * 1.5))
	else:
		curado.vitalidade += int(curado.inteligencia * 1.5)
		curado.barraVida.value = curado.vitalidade
	curado.cooldownDaCura += tempoParaCura


func subirNivel(player) -> void:
	if player == null:
		return
		
	player.nivel += 1
	player.experiencia -= player.experienciaNecessaria
	player.experienciaNecessaria = int(player.nivel * 1.2 + 40)
	player.barraExperiencia.max_value = player.experienciaNecessaria
	player.pontosExperiencia += PONTOS_STATUS_POR_NIVEL
	player.pontosStatus += PONTOS_STATUS_POR_NIVEL
