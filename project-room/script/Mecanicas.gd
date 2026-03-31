extends Node

func atacar(atacado, cooldowns: Array, forca: int, multiplicadores: Array) -> float:
	if atacado == null or atacado.vitalidade <= 0:
		return 0.0

	var indice_ataque := randi() % cooldowns.size()
	var cooldown_gerado: float = cooldowns[indice_ataque]
	var dano : float= max(forca * multiplicadores[indice_ataque] - atacado.defesa, 1)

	atacado.vitalidade -= dano
	atacado.vitalidade = max(atacado.vitalidade, 0)

	return cooldown_gerado
