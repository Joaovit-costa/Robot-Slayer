extends Node

func atacar(atacado, cooldowns: Array, forca: int, multiplicadores: Array) -> float:
	if atacado == null or atacado.vitalidade <= 0:
		return 0.0

	var indice_ataque := randi() % cooldowns.size()
	var cooldown_gerado: float = cooldowns[indice_ataque]
	var dano : float= max(forca * multiplicadores[indice_ataque] - atacado.defesa, 1)

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
	curado.vitalidade += int(curado.inteligencia * 1.5)
	curado.barraVida.value = curado.vitalidade
	curado.cooldownDaCura += tempoParaCura


func subirNivel(player):
	player.nivel += 1
	player.experiencia -= player.experienciaNecessaria
	player.experienciaNecessaria = int(player.nivel * 1.2 + 40)
	player.barraExperiencia.max_value = player.experienciaNecessaria
	player.pontosExperiencia += 3
	player.pontosStatus += 3
