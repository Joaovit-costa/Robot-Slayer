extends Resource
class_name DropData

@export_group("Dados do item")
@export var nome: String = ""
@export var quantidade: int = 0

@export_group("Chances")
@export var chance_comum: int = 0
@export var chance_incomum: int = 0
@export var chance_raro: int = 0
@export var chance_epico: int = 0
@export var chance_lendario: int = 0
