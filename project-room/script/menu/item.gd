extends Resource
class_name Item

# Nome do item
@export var nome: String = ""

# Ícone que aparece no slot
@export var icone: Texture2D

# Tipo do item: inventario, chip ou equipamento
@export var tipo: String = ""
