@tool
extends Resource
class_name ShopItemData

const CENA_BANCO_ITENS := preload("res://res/Cenas/Data/itens.tscn")

@export_group("Dados do Item")
@export var nome: String = ""
@export_range(1, 9999, 1) var preco_minimo: int = 1
@export_range(1, 9999, 1) var preco_maximo: int = 10
@export_range(1, 100, 1) var chance_aparecer: int = 100
@export_range(1, 99, 1) var quantidade: int = 1
@export var raridade: ItensData.Raridade = ItensData.Raridade.COMUM


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


func sortear_preco() -> int:
	var minimo :float= max(1, preco_minimo)
	var maximo :float= max(minimo, preco_maximo)
	return randi_range(minimo, maximo)
