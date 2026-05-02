extends Node
class_name ShopData

const CHANCE_SLOT_VAZIO := 10
const CENA_BANCO_ITENS := preload("res://res/Cenas/Data/itens.tscn")

@export_group("Catalogo")
@export var itens_loja: Array[ShopItemData] = []
@export_range(0, 100, 1) var chance_slot_vazio: int = CHANCE_SLOT_VAZIO

var banco_itens: Itens


func _ready() -> void:
	_configurar_banco_de_itens()


func _configurar_banco_de_itens() -> void:
	if banco_itens != null:
		return

	var banco_instanciado := CENA_BANCO_ITENS.instantiate()
	banco_itens = banco_instanciado as Itens
	if banco_itens != null:
		add_child(banco_itens)


func buscar_info_item(nome: String) -> ItensData:
	_configurar_banco_de_itens()
	if banco_itens == null:
		return null
	return banco_itens.buscar_item_por_nome(nome)


func sortear_ofertas(quantidade_slots: int) -> Array[Dictionary]:
	var ofertas: Array[Dictionary] = []
	for _slot in range(quantidade_slots):
		ofertas.append(_sortear_oferta())
	return ofertas


func _sortear_oferta() -> Dictionary:
	if randi_range(1, 100) <= clampi(chance_slot_vazio, 0, 100):
		return {}

	var item := _sortear_item()
	if item == null:
		return {}

	var info_item := buscar_info_item(item.nome)
	if info_item == null:
		return {}

	return {
		"nome": item.nome,
		"preco": item.sortear_preco(),
		"quantidade": max(1, item.quantidade),
		"raridade": int(item.raridade),
		"icone": info_item.icone
	}


func _sortear_item() -> ShopItemData:
	var candidatos: Array[ShopItemData] = []
	var peso_total := 0

	for item in itens_loja:
		if item == null or item.nome.strip_edges().is_empty():
			continue
		var peso := clampi(item.chance_aparecer, 0, 100)
		if peso <= 0:
			continue
		candidatos.append(item)
		peso_total += peso

	if candidatos.is_empty() or peso_total <= 0:
		return null

	var sorteio := randi_range(1, peso_total)
	var acumulado := 0
	for item in candidatos:
		acumulado += clampi(item.chance_aparecer, 0, 100)
		if sorteio <= acumulado:
			return item

	return candidatos.back()
