extends Resource
class_name ItensData

# ===== ENUMS =====
enum TipoItem { EXTENSOR, INVENTARIO, EQUIPAVEL }
enum SlotEquip { ARMA, PERSONAGEM }
enum Raridade { COMUM, INCOMUM, RARO, EPICO, LENDARIO }

# ===== DADOS BASE =====
@export_group("Dados do Item")
@export var nome: String = ""
@export var tipo: TipoItem
@export var descricao: String = ""
@export var icone: Texture2D

# ===== VISUAL =====
@export_group("Visual")
@export var cor: Color = Color.WHITE
@export var altera_aparencia: bool = false
@export var slot_equip: SlotEquip

# ===== BUFFS POR RARIDADE (%) =====
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
