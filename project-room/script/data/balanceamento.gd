class_name Balanceamento
extends RefCounted

# Toda a progressao principal usa a mesma reta entre a primeira sala e a 200.
const SALA_DIFICULDADE_MAXIMA := 200

const XP_BASE_POR_NIVEL := 60
const XP_ADICIONAL_POR_NIVEL := 12
const PONTOS_STATUS_POR_NIVEL := 2

const NIVEIS_PERDIDOS_AO_MORRER := 1
const SALAS_RECUADAS_AO_MORRER := 5
const PRIMEIRA_SALA_FORA_DO_TUTORIAL := 3

const MULTIPLICADOR_VIDA_INICIAL := 0.85
const MULTIPLICADOR_VIDA_FINAL := 8.0
const MULTIPLICADOR_DEFESA_INICIAL := 0.80
const MULTIPLICADOR_DEFESA_FINAL := 6.0
const MULTIPLICADOR_FORCA_INICIAL := 0.80
const MULTIPLICADOR_FORCA_FINAL := 3.0
const BONUS_FORCA_FINAL := 24.0
const MULTIPLICADOR_INTELIGENCIA_INICIAL := 0.80
const MULTIPLICADOR_INTELIGENCIA_FINAL := 2.5
const MULTIPLICADOR_VELOCIDADE_INICIAL := 0.90
const MULTIPLICADOR_VELOCIDADE_FINAL := 1.35
const MULTIPLICADOR_XP_INICIAL := 1.0
const MULTIPLICADOR_XP_FINAL := 4.0
const MULTIPLICADOR_MOEDAS_INICIAL := 1.0
const MULTIPLICADOR_MOEDAS_FINAL := 3.0
const MOEDAS_MINIMAS_POR_DROP := 1
const MOEDAS_MAXIMAS_POR_DROP := 4
const CHANCE_MOEDAS_SALA := 0.30
const CHANCE_MOEDAS_BOSS := 0.65
const CHANCE_ITEM_INICIAL := 0.015
const CHANCE_ITEM_FINAL := 0.04
const CHANCE_ITEM_BOSS := 0.12
const MULTIPLICADOR_COOLDOWN_INICIAL := 1.15
const MULTIPLICADOR_COOLDOWN_FINAL := 0.85
const AUMENTO_COOLDOWN_POR_INIMIGO_EXTRA := 0.18

const QUANTIDADE_INIMIGOS_INICIAL := 2
const QUANTIDADE_INIMIGOS_FINAL := 5

const BONUS_VIDA_BOSS := 1.35
const BONUS_DEFESA_BOSS := 1.20
const BONUS_FORCA_BOSS := 1.20
const BONUS_XP_BOSS := 1.50

const LIMITE_BUFF_STATUS := 0.40
const LIMITE_BUFF_VELOCIDADE := 0.30
const DEFESA_REFERENCIA := 50.0


static func progresso_da_sala(sala: int) -> float:
	return clampf(
		float(maxi(sala, 0)) / float(SALA_DIFICULDADE_MAXIMA),
		0.0,
		1.0
	)


static func experiencia_para_proximo_nivel(nivel: int) -> int:
	return XP_BASE_POR_NIVEL + max(nivel - 1, 0) * XP_ADICIONAL_POR_NIVEL


static func quantidade_inimigos_alvo(sala: int) -> int:
	return int(round(lerpf(
		float(QUANTIDADE_INIMIGOS_INICIAL),
		float(QUANTIDADE_INIMIGOS_FINAL),
		progresso_da_sala(sala)
	)))


static func chance_item_por_inimigo(sala: int, boss: bool = false) -> float:
	if boss:
		return CHANCE_ITEM_BOSS
	return interpolar(CHANCE_ITEM_INICIAL, CHANCE_ITEM_FINAL, sala)


static func chance_moedas_por_sala(boss: bool = false) -> float:
	return CHANCE_MOEDAS_BOSS if boss else CHANCE_MOEDAS_SALA


static func salas_recuadas_ao_morrer(sala: int) -> int:
	var salas_fora_do_tutorial := maxi(
		sala - PRIMEIRA_SALA_FORA_DO_TUTORIAL,
		0
	)
	return mini(SALAS_RECUADAS_AO_MORRER, salas_fora_do_tutorial)


static func interpolar(inicial: float, final: float, sala: int) -> float:
	return lerpf(inicial, final, progresso_da_sala(sala))


# Defesa tem retorno decrescente: nunca transforma ataques fortes em dano 1,
# mas cada ponto continua melhorando a sobrevivencia.
static func dano_apos_defesa(dano_bruto: float, defesa: int) -> float:
	if dano_bruto <= 0.0:
		return 0.0
	return maxf(
		dano_bruto * DEFESA_REFERENCIA
		/ (DEFESA_REFERENCIA + maxf(float(defesa), 0.0)),
		1.0
	)
