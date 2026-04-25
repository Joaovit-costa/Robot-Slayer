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
	return banco_instanciado.listar_nomes_itens()


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
