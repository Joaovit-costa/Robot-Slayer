extends Resource
class_name ItensData

# Enums que padronizam o tipo do item, o slot de equipamento e a raridade.
enum TipoItem { EXTENSOR, INVENTARIO, EQUIPAVEL }
enum SlotEquip { ARMA, PERSONAGEM }
enum Raridade { COMUM, INCOMUM, RARO, EPICO, LENDARIO }

# Campo interno usado pelo setter/getter do tipo exportado.
var _tipo: TipoItem = TipoItem.INVENTARIO

# Bloco principal com os dados base usados pelo banco e pelo inventario.
@export_group("Dados do Item")
@export var nome: String = ""
@export var tipo: TipoItem:
	get:
		return _tipo
	set(value):
		_tipo = value
		notify_property_list_changed()
@export var descricao: String = ""
@export var icone: Texture2D

# Bloco de propriedades visuais e de encaixe para itens equipaveis.
@export_group("Visual")
@export var cor: Color = Color.WHITE
@export var altera_aparencia: bool = false
@export var slot_equip: SlotEquip

# Bloco com os buffs separados por raridade para itens equipaveis.
@export_group("Buffs por Raridade (%)")
@export var buffs_por_raridade: Dictionary = {
	Raridade.COMUM: {
		"forca": 0.0,
		"defesa": 0.0,
		"velocidade": 0.0,
		"inteligencia": 0.0,
		"vitalidade": 0.0
	},
	Raridade.INCOMUM: {
		"forca": 0.0,
		"defesa": 0.0,
		"velocidade": 0.0,
		"inteligencia": 0.0,
		"vitalidade": 0.0
	},
	Raridade.RARO: {
		"forca": 0.0,
		"defesa": 0.0,
		"velocidade": 0.0,
		"inteligencia": 0.0,
		"vitalidade": 0.0
	},
	Raridade.EPICO: {
		"forca": 0.0,
		"defesa": 0.0,
		"velocidade": 0.0,
		"inteligencia": 0.0,
		"vitalidade": 0.0
	},
	Raridade.LENDARIO: {
		"forca": 0.0,
		"defesa": 0.0,
		"velocidade": 0.0,
		"inteligencia": 0.0,
		"vitalidade": 0.0
	}
}


# Esconde os buffs no inspetor quando o item nao for do tipo equipavel.
func _validate_property(property: Dictionary) -> void:
	if property.name == "buffs_por_raridade" and tipo != TipoItem.EQUIPAVEL:
		property.usage = PROPERTY_USAGE_NO_EDITOR
