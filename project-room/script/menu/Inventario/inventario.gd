extends Node
class_name Inventario

const TAMANHO_INVENTARIO = 20
var inventario: Array = []
var itens = Itens


func _ready():
	inventario.resize(TAMANHO_INVENTARIO) # índices 0–19 (slots 1–20)


func _pegar_menor_slot_livre() -> int:
	for i in range(inventario.size()):
		if inventario[i] == null:
			return i
	return -1


func adicionar_item(nome: String, quantidade: int, tipo: String) -> bool:
	# 1. Verifica se já existe no inventário
	for i in range(inventario.size()):
		var item = inventario[i]
		
		if item != null and nome in item:
			# pega o dicionário interno
			var dados = item[nome]
			
			# 2. só empilha se for do tipo "inventario"
			if dados["tipo"] == "inventario":
				dados["quantidade"] += quantidade
				return true
			
			break # existe mas não empilha
	
	# 3. não existe ou não empilha → adiciona novo slot
	var slot = _pegar_menor_slot_livre()
	
	if slot == -1:
		return false
	
	inventario[slot] = {
		(nome): {
			"quantidade": quantidade,
			"tipo": tipo,
			"idSlot": slot + 1
		}
	}
	
	return true
	
	
func remover_item(nome: String) -> bool:
	for i in range(inventario.size()):
		var item = inventario[i]
		
		if item != null and nome in item:
			inventario[i] = null
			return true
	
	return false


func get_slot(id: int) -> TextureButton:
	for child in get_parent().get_children():
		if child is TextureButton and child.idSlot == id:
			return child
	return null



func pode_usar_slot(idSlot: int) -> bool:
	var slot25 = get_slot(25)
	var slot26 = get_slot(26)

	var tem25 = slot25 and slot25.icon.texture != null
	var tem26 = slot26 and slot26.icon.texture != null

	# Se 26 tem item → libera tudo
	if tem26:
		return true

	# Se 25 tem item → libera 26 e 23
	if tem25:
		return idSlot in [25, 26, 23]

	# Se 25 vazio → bloqueia 26, 23 e 24
	if idSlot in [26, 23, 24]:
		return false

	return true
