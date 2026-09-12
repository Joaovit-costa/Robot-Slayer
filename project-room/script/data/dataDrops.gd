@tool
extends Resource
class_name DropData

const CENA_BANCO_ITENS := preload("res://res/Cenas/Data/itens.tscn")


@export_group("Dados do item")
@export var nome: String = ""
@export var quantidade: int = 0

@export_group("Chances")
@export var chance_comum: int = 0
@export var chance_incomum: int = 0
@export var chance_raro: int = 0
@export var chance_epico: int = 0
@export var chance_lendario: int = 0


# Converte o campo nome em uma lista de opcoes baseada no banco mestre.
func _validate_property(property: Dictionary) -> void:
	if property.name != "nome":
		return

	property.hint = PROPERTY_HINT_ENUM
	property.hint_string = ",".join(_listar_nomes_disponiveis())


func _listar_nomes_disponiveis() -> PackedStringArray:
	var banco_instanciado := CENA_BANCO_ITENS.instantiate() as Itens
	if banco_instanciado == null:
		return PackedStringArray()
	var nomes := banco_instanciado.listar_nomes_itens()
	banco_instanciado.free()
	return nomes


# Faz uma tentativa de drop e devolve a raridade sorteada.
func sortear_raridade() -> int:
	var tabela := [
		{"raridade": ItensData.Raridade.LENDARIO, "chance": chance_lendario},
		{"raridade": ItensData.Raridade.EPICO, "chance": chance_epico},
		{"raridade": ItensData.Raridade.RARO, "chance": chance_raro},
		{"raridade": ItensData.Raridade.INCOMUM, "chance": chance_incomum},
		{"raridade": ItensData.Raridade.COMUM, "chance": chance_comum}
	]

	for entrada in tabela:
		var chance := clampi(int(entrada.get("chance", 0)), 0, 100)
		if chance <= 0:
			continue
		if randi_range(1, 100) <= chance:
			return int(entrada.get("raridade", ItensData.Raridade.COMUM))

	return -1


# Usa os valores configurados como pesos depois que a chance de item passou.
func sortear_raridade_ponderada() -> int:
	var tabela := [
		{"raridade": ItensData.Raridade.COMUM, "peso": chance_comum},
		{"raridade": ItensData.Raridade.INCOMUM, "peso": chance_incomum},
		{"raridade": ItensData.Raridade.RARO, "peso": chance_raro},
		{"raridade": ItensData.Raridade.EPICO, "peso": chance_epico},
		{"raridade": ItensData.Raridade.LENDARIO, "peso": chance_lendario}
	]
	var peso_total := 0
	for entrada in tabela:
		peso_total += maxi(int(entrada.get("peso", 0)), 0)

	if peso_total <= 0:
		return -1

	var resultado := randi_range(1, peso_total)
	for entrada in tabela:
		resultado -= maxi(int(entrada.get("peso", 0)), 0)
		if resultado <= 0:
			return int(entrada.get("raridade", ItensData.Raridade.COMUM))

	return ItensData.Raridade.COMUM
